# ios-rubik-solver

A mobile app that detects a 3x3 Rubik's cube, recognizes the color of all cubies, solves it and provides a 3D visualisation of the solving process.

The app is written in **Objective-C** and uses **OpenCV** for all the image processing functionality. I am willing to translate the app into Swift, but due to the use of OpenCV I had some issues when trying to use the `CvPhotoCameraDelegate` on a Swift UIViewController. I am sure that a Swift port is possible, but I didn't have enough time to deal with all the hassle at this moment. Any help is appreciated! :wink: 

### Build

The project uses **CocoaPods** for all it's third-party integrations. At this moment, only OpenCV is used as a third-party library, but more may be added in the future.

First, make sure you have **CocoaPods** installed. If not, install it by typing `sudo gem install cocoapods` into a terminal window.

1. Download the repository
2. Open a Terminal window and navigate to the location of the _Podfile_
3. Type `pod install`
4. After the instalation is complete, open _RubikSolver-iOS.xcworkspace_
5. Build and run the project :smile:

### Usage

In order to detect all the six faces of the cube, we need to provide two images. One containing the first three faces, and one containing the last three faces. We capture these photos by aligning the edges of the cube with the red guidelines displayed on screen:

<img src="https://github.com/rhcpfan/ios-rubik-solver/blob/wiki/readme-images/first_three_faces.jpg" width="200">
<img src="https://github.com/rhcpfan/ios-rubik-solver/blob/wiki/readme-images/last_three_faces.jpg" width="200">

**IMPORTANT NOTICE: At this moment, the algorithm works if the order of the cube faces is given in the same order as the one in the images above! For the first image: Yellow on top, Green on left and Orange on right. For the second image: White on top, Red on left and Blue on right.**

After pressing the capture button, the flash will trigger (if available) and the photo will be taken. The next step is to process the image and extract all the cubies. Sometimes, the detection can fail, therefore we have to accept or reject the output of the detection algorithm. If we reject the detection, we'll need to capture a new photo (repeat this process until we have a good detection). An example of good and bad detections are presented bellow:

<img src="https://github.com/rhcpfan/ios-rubik-solver/blob/wiki/readme-images/good_detection.jpg" width="200">
<img src="https://github.com/rhcpfan/ios-rubik-solver/blob/wiki/readme-images/bad_detection.jpg" width="200">

The next step is to recognize the color of every cubie. In the previous step we have extracted the corners of every face of the cube. For every set of corner points, we apply a perspective transformation on the input image and obtain six separate images containing the cube faces. Some example of such images:

<img src="https://github.com/rhcpfan/ios-rubik-solver/blob/wiki/readme-images/single_face_1.jpg" width="100">
<img src="https://github.com/rhcpfan/ios-rubik-solver/blob/wiki/readme-images/single_face_2.jpg" width="100">
<img src="https://github.com/rhcpfan/ios-rubik-solver/blob/wiki/readme-images/single_face_3.jpg" width="100">

We take some samples from the center of every cubie and for every sample we extract a feature vector that we provide as an input to a pre-trained multiclass **SVM** (Support Vector Machine). The feature vector we extract contains the pixel values in **RGB** and **HSV** space (6 dimensions): **`R G B H S V`**. The output of the SVM is an **int** that represents the recognized color class. 

The recognition can fail also, therefore we provide a way to correct the result of the color recognition:

<img src="https://github.com/rhcpfan/ios-rubik-solver/blob/wiki/readme-images/color_recognition_screen.jpg" width="200">

If one of the colors was not detected propperly, we select it and tap on the correct color from the bottom toolbar.

After reviewing all faces, the next step is to generate a solution for the cube. We transform the cube configuration into the standard notation and feed it to the solver (sources are inside the project). The solver I have used is a slightly-modified version of `ckociemba`, provided by @muodov at https://github.com/muodov/kociemba. The output of the solver is a succession of turns (moves) that must be applied on the cube in order to solve it.

Example: `"D2 R' D' F2 B D R2 D2 R' F2 D' F2 U' B2 L2 U2 D R2 U"`, where `D = down`, `R = right`, `T = top`, `F = front`, `L = left` and `B = back`. An apostrophe (') means that the rotation is counter-clockwise and a "2" means that we rotate the face 180 degrees.

In the next step, we provide a visualisation of the solving process. We generate the cube in 3D by using **SceneKit** and by pressing the "Next" or "Previous" buttons, we apply the rotations provided by the solver, on the cube faces. 

<img src="https://github.com/rhcpfan/ios-rubik-solver/blob/wiki/readme-images/solving_scene_1.jpg" width="200">
<img src="https://github.com/rhcpfan/ios-rubik-solver/blob/wiki/readme-images/solving_scene_2.jpg" width="200">
<img src="https://github.com/rhcpfan/ios-rubik-solver/blob/wiki/readme-images/solving_scene_3.jpg" width="200">

A full video demo of the application is available at: https://youtu.be/g3lciIABMNI

### Roadmap

1. Since the color recognition **SVM is pre-trained using pictures of my cube**, it would be nice to include a way for the app to learn the colors of any other cube (train the liniar SVM on the device);
2. A _Swift_ version of the application;
3. A way to open and process photos of the cube from the photo gallery;
4. Any ideas?



### Why open source?

If I would have published _iOSRubikSolver_ to the AppStore, it would have been just another app that would have appeared when you searched for "Magic Cube"... I couldn't have published the app stating that it contains a **Rubik's Cube** since this is a registered trademark (please, do not try this :grimacing:). Even if I would have published it, I am 100% percent sure that I couldn't have had the same satisfaction as releasing it in the open. Even if a single person takes this code and learns something new, I consider it as a success.

This is a good project to learn something about **integration of OpenCV into an iOS app written in Objective-C** (hopefully the Swift version will follow soon), **Image Processing using OpenCV** (edge detection, contour detection, patch filtering), some **basic Machine Learning using OpenCV** (color recognition by using a pre-trained linear SVM), **SceneKit** (3D primitives creation, grouping and animations) and some basic iOS application design.

### Contributing

All contributions are welcome! Fork it, hack it and submit a pull request :wink:

### License

**iOS-Rubik-Solver** is released under the MIT license. See the LICENSE file for more details.

A slightly modified version of [this C version of the Kociemba solver](https://github.com/muodov/kociemba) was used for generating the solution. As the author states, it is released under the GPL-2 licese.
