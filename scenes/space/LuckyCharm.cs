using Godot;
using System;

public partial class LuckyCharm : CharacterBody3D
{
	public static LuckyCharm GenerateInstance() => GD.Load<PackedScene>("res://scenes/space/lucky_charm.tscn").Instantiate<LuckyCharm>();

	#region Signals and Exports
	[Signal] public delegate void SelectedEventHandler(LuckyCharm charm);
	[Signal] public delegate void DeselectedEventHandler();
	[Signal] public delegate void UnsnappingEventHandler();
	[Signal] public delegate void DeselectStartedEventHandler();
	[Signal] public delegate void HoverEnteredEventHandler();
	[Signal] public delegate void HoverExitedEventHandler();


	[ExportGroup("Nodes")]
	[Export] private NavigationAgent3D Navigation { get; set; }
	[Export] private MeshInstance3D Body { get; set; }
	[Export] private CollisionShape3D Collider { get; set; }
	[Export] private VisibleOnScreenNotifier3D VisibilityChecker { get; set; }
	[Export] private Node3D MessageLabel { get; set; }
	[Export] private Node3D MiniLabel { get; set; }
	[ExportGroup("Properties")]
	[ExportSubgroup("Wander")]
	[Export] private float WanderRange { get; set; } = 10f;
	[Export] private float Acceleration { get; set; } = 1f;
	[Export] private float Speed { get; set; } = 5.0f;
	[ExportSubgroup("Jump")]
	[Export] private Vector2 JumpIntervalMS { get; set; } = new(2000, 3000);
	[Export] private Vector2 JumpHeight { get; set; } = new(0.2f, 0.4f);
	[Export] private Vector2 JumpDurationMS { get; set; } = new(800, 1200);

	#endregion

	#region Properties
	// Camera
	public MittyCam Camera { get; set; }
	public Control OrbitControls { get; set; }
	private float CameraSnapDurationMS { get; set; } = 5000.0f;
	private Transform3D CameraSnapTransform => MessageLabel.GlobalTransform.TranslatedLocal(new Vector3(1.0f, 0.0f, 3.5f));
	private int CameraSnapStartedMS { get; set; }
	private Transform3D CameraUnsnapTransform { get; set; }
	private int CameraUnsnapStartedMS { get; set; }

	// Behavior
	public Marker3D Pivoter { get; set; }
	private int NextJumpMS { get; set; }
	private Tween JumpTween { get; set; }
	private Vector3 Destination { get; set; }

	// Attributes
	public Texture2D Avatar { get; set; }
	public Texture2D Drawing { get; set; }
	public string CharmName { get; set; }
	public string CharmMessage { get; set; }
	public Texture2D BodyTexture { get; set; }
	public Texture2D BodyTextureHeart { get; set; }

	// State
	public bool IsSelected { get; set; } = false;
	public bool SelectionDisabled { get; set; } = false;
	public bool IsOnScreen { get; set; } = false;
	public bool IsFleeing { get; set; } = false;
	public bool HasBeenFound { get; set; } = false;

	#endregion

	public override void _Ready()
	{
		// MessageLabel.Set("camera", Camera);
		// MiniLabel.Set("camera", Camera);

		// var bigLabelAvatar = MessageLabel.FindChild("Avatar") as MeshInstance3D;
		// var smallLabelAvatar = MiniLabel.FindChild("Avatar") as MeshInstance3D;

		// var material = bigLabelAvatar.Mesh.SurfaceGetMaterial(0).Duplicate(true) as StandardMaterial3D;
		// material.AlbedoTexture = Avatar;
		// bigLabelAvatar.MaterialOverride = material;

		// var material2 = smallLabelAvatar.Mesh.SurfaceGetMaterial(0).Duplicate(true) as StandardMaterial3D;
		// material2.AlbedoTexture = Avatar;
		// smallLabelAvatar.MaterialOverride = material2;

		ApplyBodyTexture(BodyTexture);
	}

	public override void _PhysicsProcess(double delta)
	{
		
		Vector3 velocity = Velocity;

		if (Camera != null)
		{   var spaceState = GetWorld3D().DirectSpaceState;
			var result = spaceState.IntersectRay(
				new PhysicsRayQueryParameters3D()
				{
					From = GlobalPosition,
					To = Camera.GlobalPosition,
					CollideWithAreas = true,
					CollideWithBodies = true,
				}
			);

			if (result.Count > 0 || !VisibilityChecker.IsOnScreen())
			{
				Undetected();
			}
			else
			{
				Detected();
			}
		}

		// Add the gravity.
		if (!IsOnFloor())
		{
			velocity += GetGravity() * (float)delta;
		}

		Wander();

		// var direction = ($NavigationAgent3D.get_next_path_position() - global_position).normalized()
		// velocity = velocity.lerp(direction * speed, accel * delta)

		var direction = (Navigation.GetNextPathPosition() - GlobalPosition).Normalized();
		Velocity = Velocity.Lerp(direction * Speed, (float)(Acceleration * delta));

		MoveAndSlide();

		// Jump();
	}


	private void OnBodyMouseEntered()
	{
		if (SelectionDisabled) return;

		Input.SetDefaultCursorShape(Input.CursorShape.PointingHand);
		EmitSignal(SignalName.HoverEntered);
	}

	private void OnBodyMouseExited()
	{
		if (SelectionDisabled) return;

		Input.SetDefaultCursorShape(Input.CursorShape.Arrow);
		EmitSignal(SignalName.HoverExited);
	}

	public override void _Input(InputEvent @event)
	{
		if (@event is not InputEventMouseButton mouse || mouse.ButtonMask == MouseButtonMask.Left) return;
		if (SelectionDisabled) return;

		if (IsSelected)
		{
			CameraUnsnapStartedMS = (int)Time.GetTicksMsec();
			EmitSignal(SignalName.Unsnapping);
		}
	}


	private void OnBodyInputEvent(Node camera, InputEvent @event, Vector3 eventPosition, Vector3 normal, int _shape_idx)
	{
		_ = camera;
		_ = eventPosition;
		_ = normal;
		_ = _shape_idx;

		// Check if is mouse press :)
		if (@event is not InputEventMouseButton mouse) return;
		if (mouse.ButtonIndex != MouseButton.Left || !mouse.Pressed) return;
		if (SelectionDisabled || IsSelected) return;

		IsSelected = !IsSelected;
		EmitSignal(SignalName.Selected, this);

		GD.Print($"Charm clicked: {CharmName}");

		// Y billboard
		// MessageLabel.Rotation = Camera.Rotation;
		// MessageLabel.Rotation = new(0.0f, MessageLabel.Rotation.Y, 0.0f);

		// Store camera location
		CameraUnsnapTransform = Camera.Transform;
		// Snap
		CameraSnapStartedMS = (int)Time.GetTicksMsec();
	}

	private void Wander()
	{
		if (Destination != Vector3.Zero && GlobalPosition.DistanceTo(Destination) > 1f) return;
		
		if (NavigationServer3D.MapGetIterationId(NavigationServer3D.GetMaps()[0]) == 0) return;


		var theta = GD.RandRange(0, Math.PI * 2);
		var phi = GD.RandRange(0, Math.PI); // I"M NOT GREEK!  THE FUCK DOES THIS MEAN?
		var radius = 50f;       // WHAT THE FUCK WAS THIS BULLSHIT?!

		var x = (float)(radius * Math.Sin(theta) * Math.Cos(phi));
		var y = (float)(radius * Math.Sin(theta) * Math.Sin(phi));
		var z = (float)(radius * Math.Cos(theta));

		Destination = new Vector3(x, y, z);
		
		Destination = NavigationServer3D.MapGetClosestPoint(NavigationServer3D.GetMaps()[0], Destination);
		Navigation.TargetPosition = Destination;
	}

	private void Jump()
	{
		if ((int)Time.GetTicksMsec() < NextJumpMS || (JumpTween != null && JumpTween.IsRunning())) return;

		NextJumpMS = (int) (Time.GetTicksMsec() + GD.RandRange(JumpIntervalMS.X, JumpIntervalMS.Y));

		var initPos = Body.GlobalPosition;
		var jumpDuration = GD.RandRange(JumpDurationMS.X / 1000, JumpDurationMS.Y / 1000);

		JumpTween = GetTree().CreateTween();
		JumpTween.TweenProperty(
			Body,
			"position:y",
			initPos.Y + GD.RandRange(JumpHeight.X, JumpHeight.Y),
			jumpDuration / 2
		).SetTrans(Tween.TransitionType.Quad);

		JumpTween.TweenProperty(
			Body,
			"position:y",
			initPos.Y,
			jumpDuration / 2
		).SetTrans(Tween.TransitionType.Quad);
	}

	private void SnapCamera()
	{
		var started = 0;
		var unsnapping = CameraUnsnapStartedMS != 0;

		// Determine start time
		if (IsSelected && !unsnapping)
			started = CameraSnapStartedMS;
		else
			started = CameraUnsnapStartedMS;

		if (started == 0) return;

		// Calculate progress
		var transitionProgress = Math.Min(
		  ((int)Time.GetTicksMsec() - started) / CameraSnapDurationMS, 1.0  
		);

		// Unsnap end
		if (CameraUnsnapStartedMS != 0 && transitionProgress >= 0.1f)
		{
			CameraUnsnapStartedMS = 0;
			IsSelected = false;
			EmitSignal(SignalName.Deselected);
			// Commit Kuriimu
			QueueFree();
			return;
		}

		// Update camera interpolation
		if (!unsnapping)
			Camera.GlobalTransform = Camera.GlobalTransform.InterpolateWith(CameraSnapTransform, (float)transitionProgress);
		else
			Camera.GlobalTransform = Camera.GlobalTransform.InterpolateWith(CameraUnsnapTransform, (float)transitionProgress);
	}

	private void Detected()
	{
		Speed = 5;
	}

	private void Undetected()
	{
		Speed = 0;
	}

	private void TransformToProp()
	{

	}

	private void GetFound()
	{

	}

	private void ApplyBodyTexture(Texture2D texture)
	{
		var bodyMaterial = Body.Mesh.SurfaceGetMaterial(0).Duplicate(true) as StandardMaterial3D;
		bodyMaterial.AlbedoTexture = texture;
		Body.MaterialOverride = bodyMaterial;
	}
}
