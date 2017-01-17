//
//  stdafx.h
//  RubikSolver-iOS
//
//  Created by Andrei Ciobanu on 17/01/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#ifdef USE_PRECOMPILED_HEADERS

#pragma once

#include "targetver.h"

#include <stdio.h>
#include <tchar.h>
#include <windows.h>

#include <opencv2/opencv.hpp>

// TODO: reference additional headers your program requires here

#ifndef _DEBUG

#pragma comment (lib, "opencv_core320.lib")
#pragma comment (lib, "opencv_highgui320.lib")
#pragma comment (lib, "opencv_imgproc320.lib")
#pragma comment (lib, "opencv_imgcodecs320.lib")
#pragma comment (lib, "opencv_ml320.lib")

#else

#pragma comment (lib, "opencv_core320d.lib")
#pragma comment (lib, "opencv_highgui320d.lib")
#pragma comment (lib, "opencv_imgproc320d.lib")
#pragma comment (lib, "opencv_imgcodecs320d.lib")
#pragma comment (lib, "opencv_ml320d.lib")

#endif

#endif
