//
//  DisplacementFilter.h
//  FingerControl
//
//  Created by Coco Ding on 3/30/15.
//  Copyright (c) 2015 Coco Ding. All rights reserved.
//

#ifndef __FingerControl__DisplacementFilter__
#define __FingerControl__DisplacementFilter__

#include <stdio.h>
#include "iterable_queue.hpp"
#include <CoreGraphics/CoreGraphics.h>

class DisplacementFilter {
    
private:
    iterable_queue<CGPoint> *_positions;
    int _bufferSize;
    
public:
    int getBufferSize();
    void setBufferSize(int bufferSize);
    
    DisplacementFilter(int bufferSize);
    ~DisplacementFilter();
    
    bool validateDisplacement(CGPoint pos);
};

#endif /* defined(__FingerControl__DisplacementFilter__) */
