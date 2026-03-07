# Understanding Loop Topology for Segment Ordering

## Mathematical Background

### What is a Loop?

In braidlab, a loop is a closed curve on a punctured disk. Key properties:
- Represented by Dynnikov coordinates `[a, b]`
- Can have multiple disjoint components
- Each component is a continuous closed curve
- Vertices are intersection points with certain arcs

### Loop Visualization Geometry

The plot method draws loops using:
1. **Semicircles** around punctures (C-shaped or D-shaped)
2. **Line segments** between adjacent punctures

### Vertices

Each vertex is uniquely identified by:
- Puncture index `p` (which puncture, 1 to n)
- Vertex index `v` (signed integer, non-zero)
  - Positive: above the puncture line
  - Negative: below the puncture line
  - Magnitude: distance from puncture (in units of gap)

## Current Implementation

### Segment Structure

Each segment in `geom` has:
```matlab
.type      = 'semicircle' | 'line'
.puncture  = [p1 p2]  % same for semicircles
.vertex    = [p1 v1; p2 v2]  % 2x2 matrix
.component = component_id
.xdata     = [x1 x2 ... xn]  % coordinates
.ydata     = [y1 y2 ... yn]
```

### Segment Generation Order

From `computeLoopGeometry`:
1. **Semicircles** at each puncture (p = 1 to n)
2. **Above segments** (M_coord) for p = 1 to n-1
3. **Below segments** (N_coord) for p = 1 to n-1

## The Ordering Problem

### What Should Happen

For a closed loop component:
- Start at any segment
- Follow connections vertex-to-vertex
- Visit each segment exactly once
- Return to starting vertex

### What's Actually Happening

Warning messages show:
```
Component 1: Path incomplete at step 11/18. 
  Current vertex (1,3) has 2 connections, all used.

Component 2: Path incomplete at step 9/26.
  Current vertex (3,-1) has 1 connections, all used.
```

This means:
- We've visited 10 segments (step 11 means we're looking for #11)
- Vertex (1,3) should have 2 edges in the graph
- Both edges have already been traversed
- But we haven't visited all 18 segments in this component

### Possible Causes

1. **Component assignment is wrong**
   - `laplaceToComponents` might be grouping unconnected segments
   - Need to verify component IDs from L.getgraph()

2. **Vertex key mismatch**
   - Segment stores vertex as [p,v] but we hash as "p_v"
   - Maybe floating point issues? (unlikely with integers)

3. **Graph topology assumption is wrong**
   - Maybe components CAN have branches or multiple disconnected pieces?
   - Need to verify each component is actually a single closed curve

4. **Endpoint tracking bug**
   - When we exit a segment, are we tracking the correct endpoint?
   - Check lines 618-625 in orderSegmentsByComponent

## Next Steps for Debugging

### A. Verify Component Assignment

Check if all 18 segments of component 1 actually form one connected graph:
1. Extract all segments with component==1
2. Build adjacency matrix of vertices
3. Check if graph is connected
4. Check if any vertex has degree > 2 (would indicate branching)

### B. Dump Vertex Connections

For the problematic vertex (1,3) at step 11:
1. Print all segments that touch vertex (1,3)
2. Show which ones are marked as used
3. Verify the segment IDs match what's in the vertex_map

### C. Review Mathematics

Questions to answer:
1. Can a loop component have branches? (No - should be Jordan curve)
2. Can a component have disconnected pieces? (No - by definition)
3. Is component assignment topological or algorithmic?
4. How does L.getgraph() determine connectivity?

## Mathematical Review Needed

From braidlab_guide.pdf or papers:
- [ ] Definition of loop components in Dynnikov representation
- [ ] How intersection numbers relate to segments
- [ ] Interpretation of M_coord and N_coord
- [ ] Graph structure from L.getgraph()
- [ ] Expected topology of plotted loops

## Test Case Analysis

Loop `[3 2 1 0 -1 -2]`:
- 4 punctures (length 6 = 2*(n-2))
- Component 1: 18 segments (what should this look like?)
- Component 2: 26 segments (what should this look like?)

Need to understand:
- Why different numbers of segments?
- How many semicircles vs lines in each?
- What is the expected topology?
