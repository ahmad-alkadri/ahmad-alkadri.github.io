---
title: "Multiple Dispatch in Julia"
date: 2025-11-03T00:27:42+09:00
aliases:
    - /2025/11/03/multiple-dispatch-in-julia
categories: ["Blog", "Programming"]
description: "On why I love Julia's multiple dispatch, how it could be applied in BIM analysis, and why I'm wishing that it's also available in other languages."
---

It's October when I started writing this draft. Autumn has finally come to Japan. Coincidentally, the first time I came to Japan back in 2022 it was also Autumn. Leaves are turning yellow and red everywhere, temperature's dropping, sunny mornings got replaced with cloudy ones and cold drizzles. It's a bit confusing period where we were debating everyday on whether to wear jacket or not, or to turn on the heater or not. It was all so familiar yet so new.

At work, the past couple of months have been quite... let's say, formative for me. Firstly, our company's platform is expanding. Scaling up. We're getting more and [more clients](https://prtimes.jp/main/html/rd/p/000000008.000136954.html). Invited to [more events](https://tektome.com/expertise-center/blog/archi-future-2025). And in the middle of all this, my role's been quite simple: lead the 3D team to conceive solutions for BIM data analysis.

## What is BIM, anyway?

Before moving forward with the content of this blog, I think I should address this first. **Building Information Modeling (BIM)** is a digital representation of a building's physical and functional characteristics. Think of it as a 3D database where every wall, beam, door, window, pipe, and electrical outlet exists as a rich, **data-laden object**. 

But, I feel that I need to underline the *data-laden* part. Because this is where the scale happens.

Now, picture a typical high-rise apartment building in Tokyo. Maybe 10 to 15 floors, each with 10 to 20 housing units. A single Revit file for such a project could easily contains **hundreds of thousands of elements**: structural columns and beams, thousands of wall segments, tens of thousands of doors and windows, complex MEP (mechanical, electrical, plumbing) systems snaking through every floor, fire safety equipment, fixtures, furniture... the list goes on. 

Not just that, each element isn't just geometry. Each of them could be data-rich objects with dozens of properties. Unlike traditional CAD drawings that are just lines and shapes, BIM elements carry properties: materials, costs, structural properties, acoustics, thermal characteristics, manufacturer and/or supplier details, and relationships to other components.

What kind of analysis do people usually do with BIM files though? Beyond managerial tasks (checking supplies, properties), we also do intensive calculations. Examples are many: **computing spatial relationships** (which elements are adjacent?), **detecting clashes** (does this pipe intersect that beam?), **extracting quantities** (how much concrete is needed?), and **performing geometric calculations** (what's the total floor area per unit?). And we need to do this across *hundreds of thousands* of objects, often in real-time for interactive applications.

It's this computational intensity, combined with the geometric complexity, that drew me back to Julia after nearly two years away.

## Multiple Dispatch

Back when I was in Luxembourg, knee-deep in numerical works and simulation code, I'd used Julia mostly for creating experimental matrix solvers and typical numerical computing. Now, after months of wrestling with geometric calculations in other languages, writing the same verbose boilerplate over and over, I felt that familiar itch: *What if I tried Julia again?*

So I fired up the REPL. And within minutes, I was reminded why I was pulled to this language in the first place back then. And it was not just because of its speed (which rivals C for well-written code), but its **elegance in abstraction**. And at the heart of that is this thing called **Multiple dispatch**.

### Wait. What *Is* Multiple Dispatch?

In a very simplified way, multiple dispatch means:  
> A function’s behavior is chosen based on the **types of all its arguments**, not just the first one.

If that's a bit hard to imagine, think of this: in functional languages like Haskell or ML, you might use pattern matching on types, but it's often limited to the structure of data rather than dynamic dispatch on multiple arguments. In procedural languages like Go or Python, you can overload functions, but it's typically based on the first argument or requires manual type checking. For example, in Python:

```python
def add(a, b):
    if isinstance(a, int) and isinstance(b, int):
        return a + b
    elif isinstance(a, float) and isinstance(b, float):
        return a + b
    elif isinstance(a, list) and isinstance(b, list):
        return a + b  # Concatenation
    else:
        raise TypeError("Unsupported types")
```

In Go, there's no function overloading at all, so you need separate function names:

```go
func addInts(a, b int) int {
    return a + b
}

func addFloats(a, b float64) float64 {
    return a + b
}

func addStrings(a, b string) string {
    return a + b
}

// To handle multiple types, you'd use interfaces (but lose type safety):
func add(a, b interface{}) interface{} {
    switch av := a.(type) {
    case int:
        if bv, ok := b.(int); ok {
            return av + bv
        }
    case float64:
        if bv, ok := b.(float64); ok {
            return av + bv
        }
    }
    return nil  // Silent failure—not ideal
}
```

### In Julia

Now in Julia, the dispatch happens automatically based on **all** argument types at runtime, without explicit checks or separate function names:

```julia
add(a, b)
```

How? Well, Julia looks at **both** `typeof(a)` *and* `typeof(b)` to decide which implementation to run.

That's it. That's multiple dispatch in Julia. Really basic example of this are as follows:

```julia
# Points.jl
struct Point2D
    x::Float64
    y::Float64
end

struct Point3D
    x::Float64
    y::Float64
    z::Float64
end

distance(p::Point2D) = sqrt(p.x^2 + p.y^2)
distance(p::Point3D) = sqrt(p.x^2 + p.y^2 + p.z^2)

# Try it
p2 = Point2D(3.0, 4.0)
p3 = Point3D(1.0, 2.0, 2.0)

println(distance(p2))  # → 5.0
println(distance(p3))  # → 3.0
```

Two types, one function name. Zero inheritance. Zero writing stuff like `distance2d` or `distance3d` or making some generics or inheritances or writing some conditionals based on `typeof`. 

Just clean, composable logic.

### OK, but what does it do with BIM?

Let's start with something simple, an analysis that people like me often do on BIM data: *spatial analysis*. During spatial analysis, we'll be constantly adding points, scaling vectors, rotating meshes. In real life, simple questions like:

> *"List all bathrooms that are in the fifth floor and find if there's any of them that is oversized."*

Will involve getting all the bathrooms' instances, vertices, matrices--transforming them to their proper position--and then do *intersecting check* with the adjacent walls--which means getting all the walls' instances, vertices, matrices--transforming them to their proper position before operating on them.

(Of course, that's assuming we've successfully filtered those BIM elements so we only have those on the fifth floor, but that's a whole other blog post)

So how does multiple dispatch help? Again, let's go with some examples.

#### Example 1: Basic Geometric Operations

With multiple dispatch, adding more implementations for base operators like `+` becomes trivial and *type-safe*.

```julia
import Base.+ # Importing base plus symbol function

# Add implementations for points in 2D and 3D
+(a::Point2D, b::Point2D) = Point2D(a.x + b.x, a.y + b.y)
+(a::Point3D, b::Point3D) = Point3D(a.x + b.x, a.y + b.y, a.z + b.z)

# Even for vectors!
struct Vec2D
    dx::Float64
    dy::Float64
end

+(p::Point2D, v::Vec2D) = Point2D(p.x + v.dx, p.y + v.dy)
+(v::Vec2D, p::Point2D) = p + v  # commutative convenience
```

With those new implementations in place, we can now write natural expressions:

```julia
origin = Point2D(0.0, 0.0)
offset = Vec2D(10.0, 5.0)
new_point = origin + offset  # → Point2D(10.0, 5.0)
```

No wrapper classes. No method overloading via long function names like `addPointToPoint2D`. Just `+`, dispatched correctly based on what you feed it.

And because Julia compiles specialized machine code for each method, this isn't just pretty to look at: it is **fast**. Critical when you're processing thousands of building elements. Hundreds of thousands of points, vectors. Maybe millions of them.

#### Example 2: Bounding Box Calculations

Next example is bounding box calculations. In BIM, we constantly need to compute bounding boxes for spatial queries. Multiple dispatch makes this elegant across different geometric primitives:

```julia
# Different BIM element types
struct Wall
    start_point::Point3D
    end_point::Point3D
    height::Float64
    thickness::Float64
end

struct Door
    center::Point3D
    width::Float64
    height::Float64
    rotation::Float64
end

struct Room
    corners::Vector{Point3D}
    floor_level::Float64
    ceiling_level::Float64
end

# Bounding box type
struct BoundingBox
    min::Point3D
    max::Point3D
end

# Multiple dispatch: compute bounding box for different element types
function bounding_box(w::Wall)
    x_vals = [w.start_point.x, w.end_point.x]
    y_vals = [w.start_point.y, w.end_point.y]
    z_vals = [w.start_point.z, w.start_point.z + w.height]
    
    BoundingBox(
        Point3D(minimum(x_vals), minimum(y_vals), minimum(z_vals)),
        Point3D(maximum(x_vals), maximum(y_vals), maximum(z_vals))
    )
end

function bounding_box(d::Door)
    # Simplified: assumes door is axis-aligned (ignoring rotation for this example)
    half_width = d.width / 2
    half_height = d.height / 2
    
    BoundingBox(
        Point3D(d.center.x - half_width, d.center.y - half_height, d.center.z),
        Point3D(d.center.x + half_width, d.center.y + half_height, d.center.z + d.height)
    )
end

function bounding_box(r::Room)
    x_coords = [p.x for p in r.corners]
    y_coords = [p.y for p in r.corners]
    
    BoundingBox(
        Point3D(minimum(x_coords), minimum(y_coords), r.floor_level),
        Point3D(maximum(x_coords), maximum(y_coords), r.ceiling_level)
    )
end

# Now we can uniformly query bounding boxes:
wall = Wall(Point3D(0,0,0), Point3D(10,0,0), 3.0, 0.2)
door = Door(Point3D(5,0,1), 0.9, 2.1, 0.0)
room = Room([Point3D(0,0,0), Point3D(10,0,0), Point3D(10,8,0), Point3D(0,8,0)], 0.0, 3.0)

bbox_wall = bounding_box(wall)
bbox_door = bounding_box(door)
bbox_room = bounding_box(room)
```

One function name, three different implementations. No inheritance hierarchy needed.

#### Example 3: Intersection Tests

For clash detection and spatial queries, we need intersection tests between different element types. Watch how dispatch chains elegantly:

```julia
# Check if two bounding boxes intersect
function intersects(a::BoundingBox, b::BoundingBox)
    return (a.min.x <= b.max.x && a.max.x >= b.min.x) &&
           (a.min.y <= b.max.y && a.max.y >= b.min.y) &&
           (a.min.z <= b.max.z && a.max.z >= b.min.z)
end

# Check if a point is inside a bounding box
function intersects(p::Point3D, box::BoundingBox)
    return (box.min.x <= p.x <= box.max.x) &&
           (box.min.y <= p.y <= box.max.y) &&
           (box.min.z <= p.z <= box.max.z)
end

# Check if a door intersects with a wall (converts to bounding box comparison)
function intersects(d::Door, w::Wall)
    door_box = bounding_box(d)
    wall_box = bounding_box(w)
    return intersects(door_box, wall_box)  # Dispatch to BoundingBox-BoundingBox method!
end

# Check if a room contains a door (checks if door center is in room)
function intersects(r::Room, d::Door)
    room_box = bounding_box(r)
    door_center = d.center
    return intersects(door_center, room_box)  # Dispatch to Point3D-BoundingBox method!
end

# Usage is beautifully uniform:
if intersects(door, wall)
    println("Door intersects with wall - possible opening")
end

if intersects(room, door)
    println("Door is within room bounds")
end
```

Same function name, but multiple implementations. Notice how the Door-Wall check *composes* the BoundingBox-BoundingBox check? That's called dispatch chaining, and I honestly think it's really hard to achieve this elegantly in languages without multiple dispatch.

#### Example 4: Transformation Matrices

BIM elements often need transformation in 3D space. For instance, placing prefabricated wall sections, rotating HVAC components to fit constraints, or scaling temporary structures. Multiple dispatch handles different transformation types elegantly by letting the type system determine *which* transformation logic applies:

```julia
# Different transformation types
struct Translation
    offset::Point3D
end

struct Rotation
    angle::Float64  # radians
    axis::Point3D   # rotation axis
end

struct Scale
    factor::Float64
end

# Apply transformations to points (fundamental building block)
function transform(p::Point3D, t::Translation)
    Point3D(p.x + t.offset.x, p.y + t.offset.y, p.z + t.offset.z)
end

function transform(p::Point3D, r::Rotation)
    # Full 3D rotation using Rodrigues' rotation formula
    # Rotates point p by angle r.angle around axis r.axis
    
    # Normalize the rotation axis
    axis = r.axis
    axis_length = sqrt(axis.x^2 + axis.y^2 + axis.z^2)
    if axis_length == 0
        return p  # No rotation if axis is zero
    end
    k_x = axis.x / axis_length
    k_y = axis.y / axis_length
    k_z = axis.z / axis_length
    
    # Rodrigues' formula: v_rot = v*cos(θ) + (k × v)*sin(θ) + k*(k·v)*(1-cos(θ))
    cos_θ = cos(r.angle)
    sin_θ = sin(r.angle)
    one_minus_cos = 1.0 - cos_θ
    
    # Dot product: k · v
    k_dot_v = k_x * p.x + k_y * p.y + k_z * p.z
    
    # Cross product: k × v
    cross_x = k_y * p.z - k_z * p.y
    cross_y = k_z * p.x - k_x * p.z
    cross_z = k_x * p.y - k_y * p.x
    
    # Apply Rodrigues' formula
    Point3D(
        p.x * cos_θ + cross_x * sin_θ + k_x * k_dot_v * one_minus_cos,
        p.y * cos_θ + cross_y * sin_θ + k_y * k_dot_v * one_minus_cos,
        p.z * cos_θ + cross_z * sin_θ + k_z * k_dot_v * one_minus_cos
    )
end

function transform(p::Point3D, s::Scale)
    Point3D(p.x * s.factor, p.y * s.factor, p.z * s.factor)
end

# Transform entire walls
function transform(w::Wall, t::Translation)
    Wall(
        transform(w.start_point, t),
        transform(w.end_point, t),
        w.height,
        w.thickness
    )
end

function transform(w::Wall, s::Scale)
    Wall(
        transform(w.start_point, s),
        transform(w.end_point, s),
        w.height * s.factor,
        w.thickness * s.factor
    )
end

function transform(w::Wall, r::Rotation)
    Wall(
        transform(w.start_point, r),
        transform(w.end_point, r),
        w.height,
        w.thickness
    )
end

# Transform doors
function transform(d::Door, t::Translation)
    Door(
        transform(d.center, t),
        d.width,
        d.height,
        d.rotation
    )
end

# Chain transformations naturally:
point = Point3D(1.0, 0.0, 0.0)
translated = transform(point, Translation(Point3D(5.0, 5.0, 0.0)))
rotated = transform(translated, Rotation(π/4, Point3D(0,0,1)))
scaled = transform(rotated, Scale(2.0))
```

#### Example 5: Area and Volume Calculations

Different elements need different calculation methods:

```julia
# Helper: distance between two points
function distance(p1::Point3D, p2::Point3D)
    sqrt((p1.x - p2.x)^2 + (p1.y - p2.y)^2 + (p1.z - p2.z)^2)
end

# Calculate area/volume for different types
function volume(w::Wall)
    length = distance(w.start_point, w.end_point)
    length * w.height * w.thickness
end

function volume(r::Room)
    # Simplified: assumes rectangular room
    corners = r.corners
    length = distance(corners[1], corners[2])
    width = distance(corners[2], corners[3])
    height = r.ceiling_level - r.floor_level
    length * width * height
end

function area(r::Room)
    # Floor area
    corners = r.corners
    length = distance(corners[1], corners[2])
    width = distance(corners[2], corners[3])
    length * width
end

function area(w::Wall)
    # Wall surface area
    length = distance(w.start_point, w.end_point)
    length * w.height
end

# Now we can write generic analysis functions:
function total_volume(elements::Vector)
    sum(volume(elem) for elem in elements)
end

# Works with any collection of elements that have a volume method!
# Create some example walls
bathroom_walls = [
    Wall(Point3D(0,0,0), Point3D(3,0,0), 2.5, 0.15),
    Wall(Point3D(3,0,0), Point3D(3,2,0), 2.5, 0.15),
    Wall(Point3D(3,2,0), Point3D(0,2,0), 2.5, 0.15),
    Wall(Point3D(0,2,0), Point3D(0,0,0), 2.5, 0.15)
]
bathroom_volume = total_volume(bathroom_walls)
```

#### Example 6: Real-World Application: Finding Oversized Bathrooms

Alright, now that we have done some examples on how multiple dispatch can be used in BIM operations, do you still remember that query from earlier? Well, we can now solve it as follows:

```julia
function is_oversized_bathroom(room::Room, threshold_area::Float64)
    room_area = area(room)
    return room_area > threshold_area
end

function analyze_floor(rooms::Vector{Room}, floor_level::Float64, area_threshold::Float64)
    # Filter rooms on the specified floor
    floor_rooms = filter(r -> r.floor_level ≈ floor_level, rooms)
    
    # Find oversized ones (architectural finding: bathrooms shouldn't exceed threshold)
    oversized = filter(r -> is_oversized_bathroom(r, area_threshold), floor_rooms)
    
    # Report results with geometric context
    for room in oversized
        bbox = bounding_box(room)
        room_area = area(room)
        println("⚠ Oversized room: $(room_area) m² at position ($(bbox.min.x), $(bbox.min.y))")
    end
    
    return oversized
end

# Usage:
all_rooms = [
    Room([Point3D(0,0,0), Point3D(3,0,0), Point3D(3,2,0), Point3D(0,2,0)], 5.0, 8.0),  # Floor 5
    Room([Point3D(0,0,0), Point3D(4,0,0), Point3D(4,3,0), Point3D(0,3,0)], 5.0, 8.0),  # Floor 5, larger
    Room([Point3D(0,0,0), Point3D(2,0,0), Point3D(2,1.5,0), Point3D(0,1.5,0)], 6.0, 9.0) # Floor 6
]

fifth_floor_bathrooms = analyze_floor(all_rooms, 5.0, 8.0)  # 8m² threshold
```

All of these functions--bounding boxes, intersections, transformations, calculations--they use the same names across wildly different types. No inheritance pyramids. No visitor patterns. No type switches. Just **methods dispatching on types**.

#### Example 7: Clearance Checks

In BIM analysis, elements don't exist in isolation. A door needs to know if it fits in a wall. A pipe needs to avoid beams. A room needs to contain furniture. These are **cross-type interactions**, and multiple dispatch handles them beautifully. 

Consider checking if there's enough clearance between different element types:

```julia
# Additional element types for cross-type interactions
struct Pipe
    start_point::Point3D
    end_point::Point3D
    diameter::Float64
end

struct Beam
    start_point::Point3D
    end_point::Point3D
    cross_section_width::Float64
    cross_section_height::Float64
end

struct Furniture
    center::Point3D
    width::Float64
    depth::Float64
    height::Float64
end

# Extend bounding_box for new types
function bounding_box(p::Pipe)
    radius = p.diameter / 2
    BoundingBox(
        Point3D(min(p.start_point.x, p.end_point.x) - radius, 
                min(p.start_point.y, p.end_point.y) - radius,
                min(p.start_point.z, p.end_point.z) - radius),
        Point3D(max(p.start_point.x, p.end_point.x) + radius,
                max(p.start_point.y, p.end_point.y) + radius,
                max(p.start_point.z, p.end_point.z) + radius)
    )
end

function bounding_box(b::Beam)
    BoundingBox(
        Point3D(min(b.start_point.x, b.end_point.x) - b.cross_section_width/2,
                min(b.start_point.y, b.end_point.y) - b.cross_section_height/2,
                min(b.start_point.z, b.end_point.z) - b.cross_section_height/2),
        Point3D(max(b.start_point.x, b.end_point.x) + b.cross_section_width/2,
                max(b.start_point.y, b.end_point.y) + b.cross_section_height/2,
                max(b.start_point.z, b.end_point.z) + b.cross_section_height/2)
    )
end

function bounding_box(f::Furniture)
    BoundingBox(
        Point3D(f.center.x - f.width/2, f.center.y - f.depth/2, f.center.z),
        Point3D(f.center.x + f.width/2, f.center.y + f.depth/2, f.center.z + f.height)
    )
end

# Helper: minimum distance between two bounding boxes
function minimum_distance(box1::BoundingBox, box2::BoundingBox)
    # Returns 0 if overlapping, otherwise minimum separation
    if intersects(box1, box2)
        return 0.0
    end
    
    # Calculate minimum separation distance
    dx = max(box1.min.x - box2.max.x, box2.min.x - box1.max.x, 0)
    dy = max(box1.min.y - box2.max.y, box2.min.y - box1.max.y, 0)
    dz = max(box1.min.z - box2.max.z, box2.min.z - box1.max.z, 0)
    
    sqrt(dx^2 + dy^2 + dz^2)
end

# Different clearance rules for different element combinations

# Pipe-to-beam clearance (stricter for structural elements)
function check_clearance(pipe::Pipe, beam::Beam, min_distance::Float64 = 0.15)
    pipe_box = bounding_box(pipe)
    beam_box = bounding_box(beam)
    
    # Calculate minimum distance between bounding boxes
    dist = minimum_distance(pipe_box, beam_box)
    return dist >= min_distance, dist
end

# Door-to-wall clearance (different logic entirely)
function check_clearance(door::Door, wall::Wall, min_distance::Float64 = 0.05)
    # Doors should be *in* walls, so we check if door is properly embedded
    door_box = bounding_box(door)
    wall_box = bounding_box(wall)
    
    # Check if door is within wall thickness tolerance
    is_embedded = intersects(door_box, wall_box)
    if is_embedded
        # Check if door doesn't extend beyond wall height
        extends_beyond = door_box.max.z > wall_box.max.z
        return !extends_beyond, 0.0
    else
        return false, minimum_distance(door_box, wall_box)
    end
end

# Furniture-to-door clearance (accessibility requirements)
function check_clearance(furniture::Furniture, door::Door, min_distance::Float64 = 0.80)
    # Need wider clearance for accessibility
    furn_box = bounding_box(furniture)
    door_box = bounding_box(door)
    
    dist = minimum_distance(furn_box, door_box)
    return dist >= min_distance, dist
end

# Now use it:
hvac_pipe = Pipe(Point3D(0,0,2.0), Point3D(5,0,2.0), 0.1)
structural_beam = Beam(Point3D(0,0,3.0), Point3D(5,0,3.0), 0.3, 0.5)
entry_door = Door(Point3D(1.5,0,0), 0.9, 2.1, 0.0)
exterior_wall = Wall(Point3D(0,0,0), Point3D(10,0,0), 3.0, 0.2)
desk = Furniture(Point3D(2,1,0), 1.2, 0.6, 0.75)
office_door = Door(Point3D(3,1.5,0), 0.9, 2.1, 0.0)

pipe_clear, pipe_dist = check_clearance(hvac_pipe, structural_beam)
door_clear, door_dist = check_clearance(entry_door, exterior_wall)
furniture_clear, furn_dist = check_clearance(desk, office_door, 1.0)  # Override default
```

**Same function name. Three completely different implementations.** Each pair of types gets its own logic, with its own default parameters, its own calculation method, and its own return semantics.

Try writing that in Go or Python without either:
- A massive switch statement on type combinations
- A complex visitor pattern
- Losing type safety entirely

### The Golang Reality Check

After months of writing Go for infrastructure tooling, coming back to Julia felt like breathing fresh air.

Now, I love Go. Its simplicity, its concurrency model (I haven't found other programming language that implements async as beautifully as Go so far), its tooling, they're all excellent for building reliable systems. But when it comes to the kind of polymorphic behavior we need in BIM analysis? Go makes us work *hard*.

Let's take that clearance check example. Remember how clean it was in Julia? Here's what the Go equivalent looks like:

```go
// Separate functions for every type combination
func CheckClearancePipeBeam(pipe Pipe, beam Beam, minDistance float64) (bool, float64) {
    pipeBox := BoundingBoxFromPipe(pipe)
    beamBox := BoundingBoxFromBeam(beam)
    dist := MinimumDistance(pipeBox, beamBox)
    return dist >= minDistance, dist
}

func CheckClearanceDoorWall(door Door, wall Wall, minDistance float64) (bool, float64) {
    doorBox := BoundingBoxFromDoor(door)
    wallBox := BoundingBoxFromWall(wall)
    // ... different logic here
}

func CheckClearanceFurnitureDoor(furniture Furniture, door Door, minDistance float64) (bool, float64) {
    // ... and different logic here
}

// And you'd need even more for different orderings:
func CheckClearanceBeamPipe(beam Beam, pipe Pipe, minDistance float64) (bool, float64) {
    // Wait, is this different from PipeBeam? Do I need this?
}
```

Already verbose. But it gets worse when we want to handle them generically.

We *could* use interfaces:

```go
type BIMElement interface {
    BoundingBox() BoundingBox
}

func CheckClearance(elem1, elem2 BIMElement, minDistance float64) (bool, float64) {
    // But now you've lost all the specific logic!
    // Every element just becomes a bounding box
    box1 := elem1.BoundingBox()
    box2 := elem2.BoundingBox()
    
    // What about door-in-wall logic? What about material checks?
    // You'd need type switches:
    switch e1 := elem1.(type) {
    case Door:
        switch e2 := elem2.(type) {
        case Wall:
            // Door-wall specific logic
        case Room:
            // Door-room specific logic
        }
    case Pipe:
        switch e2 := elem2.(type) {
        case Beam:
            // Pipe-beam specific logic
        case Wall:
            // Pipe-wall specific logic
        }
    // ... and so on for every combination
    }
}
```

This explodes *combinatorially*. With 5 element types, we're looking at 25 potential combinations. With 10 types? 100 combinations. (My math probably wrong on the exact number; CMIIW). And every single one needs its own case in a nested switch statement.

Or you go full OOP and do:

```go
type Clearable interface {
    CheckClearanceWith(other Clearable, minDistance float64) (bool, float64)
}

func (p Pipe) CheckClearanceWith(other Clearable, minDistance float64) (bool, float64) {
    // Now you're back to type assertions anyway
    switch elem := other.(type) {
    case Beam:
        // Pipe-beam logic
    case Wall:
        // Pipe-wall logic
    default:
        // Generic fallback
    }
}
```

Still type switches. Still combinatorial complexity. And you've lost type safety—the compiler won't tell you if you forgot to handle a specific pair.

Compare this to Julia:
```julia
check_clearance(pipe::Pipe, beam::Beam, min_distance::Float64 = 0.15) = ...
check_clearance(door::Door, wall::Wall, min_distance::Float64 = 0.05) = ...
```

Two lines. Type-safe. Nice and elegant.

Go being very simple is a big advantage for some contexts. But for problems requiring rich type interactions, like BIM analysis, game engines, scientific computing, it forces you into verbose, error-prone patterns. At the same time, Julia just... *gets it*.

---

### So… Why Isn't Everyone Doing This?

Honestly, I don't know. Multiple dispatch feels like one of programming's best-kept secrets. Me not being a computer science graduates honestly probably hindered me from getting exposed to this earlier. But reading the history a little bit more, multiple dispatch is clearly not really a secret. Dispatch as a concept itself dated way back then. And Julia programming language made the choice of making multiple dispatch as its primary paradigm.

The language was created in 2012 by four researchers at MIT: Jeff Bezanson, Stefan Karpinski, Viral Shah, and Alan Edelman (a professor of applied mathematics). They were frustrated with the "two-language problem", which is writing high-level code in MATLAB or Python for prototyping, then rewrite performance-critical parts in C or Fortran. They wanted one language that combined the ease of MATLAB with the speed of C.

But more importantly, they wanted a language that **thinks like mathematicians think**.

In mathematics, you don't write `add_real_numbers(a, b)` and `add_complex_numbers(c, d)`. You write $f(x)$ and the context determines what $f$ means. Addition works on reals, complexes, matrices, polynomials. The *operation* is conceptually the same, but the *implementation* differs based on the operands.

This is **exactly** what multiple dispatch enables. The function name represents the mathematical concept. The types determine the concrete behavior. It's declarative. It's compositional. It's how we naturally think about mathematical operations.

And that's why Julia feels so natural for scientific computing. It mirrors mathematical notation and thought processes in a way that many other languages simply don't. When you write:

```julia
A + B
```

You're not going to think "is `A` an object with an `add` method?" Instead, you'll be thinking "what are `A` and `B`, and how should addition work for them?" That's multiple dispatch.

Disclaimer: I'm not a mathematician. But somehow I spent years in academia (probably too long, but that's another blog post!) surrounded by people who think in equations and abstractions. And maybe that's why Julia resonates with me so deeply.

Yet most mainstream languages stick to single dispatch or procedural overloading. Why?

### What’s Next?

Honestly? I'm now seriously considering integrating Julia into our BIM pipeline--especially for geometry-heavy preprocessing tasks. The speed is there, the expressiveness is there, and the interop story is improving.

The question, of course, is *how*. We can't just insert whole new code in an already scaling, established platform. Maybe lambda function? Separated microservices? Undecided.

And that's actually makes me wonder: should I also try to make a REST API server with Julia? Maybe in the next post.

By the way, the whole examples above can be found in [this notebook](https://colab.research.google.com/drive/1_Fr4q0SI9HyOX53RpGz0b-gOGPhVRzWq?usp=sharing). Let me know if you have any questions (leave some comments here or reach me on LinkedIn). 

Thank you for reading!