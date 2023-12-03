# 3D Render/augmented reality in Stormworks
[Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2793934450)  
[Video of workshop vehicle](https://youtu.be/bEB1MxJJ7Qk)  
  
![Screenshot of the vehicle in game in 1st person, showing the rendering on HUD. On the HUD both LIDAR points and triangles for colored box meshes are visible.](<Pictures/Screenshot 2023-11-29 173559 - 1st_person.png>)  
![Close up screenshot of the vehicle in game in 3rd person.](<Pictures/Screenshot 2023-11-29 173955 - 3rd_person.png>)  

## Theory
### Camera Transform
3D camera that can rotate and move around is made by calculating the 4x4 camera transform matrix:  
<code>cameraTransformMatrix = perspectiveProjectionMatrix \* rotationMatrixZYX<sup>T</sup> \* translationMatrix</code>  
  
The perspectiveProjectionMatrix is an asymmetric viewing frustum, where the position of the camera/player head relative to the screen is accounted for to achieve AR.  
[Deriving/Explanation of the used perspectiveProjectionMatrix.](https://youtu.be/U0_ONQQ5ZNM)  
The perspectiveProjectionMatrix is pretty much just the camera, but it cannot rotate nor move around, as it is just at the origin and looking down the z-axis.
  
The rotationMatrixZYX is 3 rotation matrices multiplied together in the order ZYX. [Example](https://www.songho.ca/opengl/gl_anglestoaxes.html#anglestoaxes)  
And the transposed of said combined matrix is used, which is equivilent to the inverse matrix due to rotation matrices being orthonormal. [Wikipedia/Orthogonal_matrix](https://en.wikipedia.org/wiki/Orthogonal_matrix)  

The translationMatrix is a 4x4 identity matrix, but the 4th column is <code>\<-x, -y, -z, 1\></code>, in which coordinates are the camera world position.  
  
How this define the camera is that the translationMatrix subtract the camera position from a point, making the point relative to the camera. Then instead of rotating the camera defined by perspectiveProjectionMatrix to the rotation of the world rotation, then we do the inverse rotation of taking the relative point and rotate it to the local rotation of the perspectiveProjectionMatrix, which is important as it keeps the screen axis aligned, making further calculations simple.
Then the perspectiveProjectionMatrix, which is still at its own local origin and looking down the z-axis can project the point onto the screen.  
(Point is first transformed to clip space by matrix multiplication with cameraTransformMatrix. Then perspective division by *w* and going from NDC space to screen space)


### 3D Point Projection
To project/transform any 3D world point onto the screen, then let <code>point<sub>world</sub> = \<x, y, z, w\></code>, where **point<sub>world</sub>.w** is implicitly set to 1. Then do matrix multiplication of **cameraTransformMatrix** and **point<sub>world</sub>**:  
<code>point<sub>clip</sub> = cameraTransformMatrix \* point<sub>world</sub></code>  
  
point<sub>clip</sub>, that is in clip space, is then checked if visible/in frustum by testing each frustum plane:  
<code>0<=z and z<=w and -w<=x and x<=w and -w<=y and y<=w</code>
  
If inside frustum then do perspective division, which goes from clip space to Normalized Device Coordinate (NDC) space.  
<code>point<sub>NDC</sub> = point<sub>world</sub>.xyz / point<sub>world</sub>.w</code>  
The range of points in NDC space with the used camera transform matrix is: <code>x, y ∈ [-1, 1], z ∈ [0, 1]</code>  
  
Then go from NDC space to screen space by multiplying by half the **pixels (px)** of respectively width and height and offset to the screen center:  
<code>point<sub>screen</sub>.x = point<sub>NDC</sub>.x \* px<sub>width</sub>/2 + px<sub>width</sub>/2</code>  
<code>point<sub>screen</sub>.y = point<sub>NDC</sub>.y \*  px<sub>height</sub>/2 + px<sub>height</sub>/2</code>  
  
Extra thing is that **point<sub>NDC</sub>.z** is not linear in the range [0, 1], but can be made so by: <code>linear_depth = near / (far + point<sub>NDC</sub>.z \* (near - far))</code>, where *near* and *far* are the distances to near and far plane used in perspectiveProjection matrix. Distance along local z-axis is then <code>linear_depth \* far</code>.


### 3D Triangle Projection
Transform every 3 vertices of the triangle to clip space, then if any vertex is behind the near or far plane then discard triangle. Else then check if any of the vertices are within the 4 other frustum planes then accept triangle to a buffer table of triangles in screen space.  
(This step is good enough for Stormworks and will render most triangles that are in view and frustum cull others that are not, assuming triangles are reasonably sized. The better or full implementation would be to apply the [Sutherland–Hodgman algorithm](https://en.wikipedia.org/wiki/Sutherland%E2%80%93Hodgman_algorithm) (I think), which would iterate over each frustum plane and clip the triangle so it is inside the frustum, but by clipping a triangle that is partially inside would make more triangles.
This would only be reasonable to do with the near plane, due to vertex being behind the screen. Creating more triangles to draw in Stormworks would only decrease performance, as the draw triangle function already does clipping (Or something alike), so drawing more triangles would do worse. Also implementation of algorithm would take a great chunk of chars.)
  
If every triangle have the same winding order of clock-wise or counter clock-wise, then a backface culling test can be done to determine if the triangle is facing the camera.  
  
Then after checking every triangle and add accepted ones to the buffer, then do [painter's algorithm](https://en.wikipedia.org/wiki/Painter%27s_algorithm), which is sorting the table of triangles based on their centroid depth value calculated by <code>v1.z + v2.z + v3.z</code>, where *v...* are the triangle vertices in screen space. (Or NDC space for z-component)  
  
Then draw each triangle back to forth by linear iteration of buffer table.  
  
A performance improvement is to only transform each unique vertex to screen space once. Assuming a mesh of triangles is rendered, then a great deal of vertices would be shared.


### Stormworks Microcontroller/Lua Limitation
- There is a set limit of chars per lua script to 4096 chars, which is annoying.
- A lua script can recieve and output data with composite node, which contains 32 32bit numbers and 32 booleans. This is the only way to share data between lua scripts if char limit is exceeded and need to split up into more scripts if possible.
- In the microcontroller, for each link between nodes there is introduced a tick delay (There are 60 ticks per second), so also need to do a rotation and position estimation of the camera to predict about 4 ticks into the future so it overlays correctly with the world.


### Stormworks Monitors/HUD Size And Relative Positions
![Shows the 1x1 HUD surrounded by paint blocks, used for absoloute size reference, when ruling lengths with pixels.](<Pictures/1x1 HUD size approximation.png>)  
Picture shows the 1x1 HUD with all 32x32 pixels lit and the HUD is surrounded by paint blocks. The paint blocks, which has a 9x9 grid on their face, is used for an absoloute length. Since a block is 0.25 meters then a paintable grid has a length of 0.25/9 meter.  
Then calculating an estimate of actual screen lengths by counting pixels, which is estimated to a spacing between the model edge and actual screen to be <code>0.02</code> meters at the sides and <code>0.01</code> at the top and <code>0.03</code> at the bottom.  
  
It is then concluded that the screen size of a HUD is <code>model_length - 2\*0.02</code>, and has an offset from the center of the model on the second axis of <code>0.01</code> meters.  
So 1x1 HUD <code>sizeX|Y = 0.21</code> meters and 3x3 HUD <code>sizeX|Y = 0.71</code>, with both having a <code>0.01</code> offset on the second axis.  
  
Other monitors has been estimated to have a screen size calculated by <code>model_length - 2\*0.022</code>, but is symmetrical on both axis.  
  
Another small thing, which is accounted for in code is that the screens has a small depth into the model, in which 0.01 meters is used for both screen types. Accurate for HUDs, but other monitors do have a very little more depth, but with screens pixel quantity, then it is not like it really matters or is noticeable.
  
![Shows a subset of the example vehicle, in which local coordinate system is overlayed. The red colored sides shows where the seat is obstructing/taking place, and greeen is showing that there is a block free of space between the HUD and seat.](<Pictures/Local Coordinate Space.png>)  
In the picture a subset of the example vehicle is showed, in which a local coordinate system is overlayed, showing that it is at the center of the block of the seat headrest. This is the block where you want to offset the physics sensor GPS to.


### In Game Microcontroller Property Paremeters
| `Property`      | `Example_Value` | `Description` |
| --------------- | --------------- | ------------- |
| w               | 96              | Pixel width of screen. |
| h               | 96              | Pixel height of screen. |
| near            | 0.25            | Distance to near plane in meters, but in code there's an offset added, which is the distance from seat headrest block to the end of (compact) seat model + screen depth in model. <br />**So** ***near*** is the distance from the end of (compact) seat model to the screen. I.e how many blocks between (compact) seat and screen divided by 4. |
| far             | 1000            | Distance to far plane in meters, max render distance. |
| sizeX           | 0.71            | Physical sizeX/width of screen in meters. (Important that it is the actual screen part with pixels and not model width) |
| sizeY           | 0.71            | Physical sizeY/height of screen in meters. (Important that it is the actual screen part with pixels and not model height) |
| positionOffsetX | 0               | Physical offset in the XY plane along X:right in meters. |
| positionOffsetY | 0.01            | Physical offset in the XY plane along Y:up in meters. (For example the HUD screen is 0.01 m offset in the model upwards) |
| pxOffsetX       | 0               | Optional pixel offset. |
| pxOffsetY       | 0               | Optional pixel offset. |
| tick            | 4               | Tick compensation due to tick delay in microcontroller. |
| GPS_to_camera   | 0, 1, -1        | Offset from physics sensor block to seat headrest block. (X:right, Y:up, Z:forward) |


## In game implementation
![Description of the microcontroller used in: In game example](<Pictures/Microcontroller Description.png>)  
  
To implement the camera I decided to split up the process in 2 lua scripts for more breathing room. (But you could squeeze both systems in one lua script, for example a simple LIDAR.)
CameraTransform.lua calculates the 4x4 cameraTransformMatrix and sends the 16 numbers of the matrix to the next script, Render.lua, which then only needs the render function using the cameraTransformMatrix and (LIDAR) points or triangle data to render.