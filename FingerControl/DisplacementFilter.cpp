//
//  DisplacementFilter.cpp
//  FingerControl
//
//  Created by Coco Ding on 3/30/15.
//  Copyright (c) 2015 Coco Ding. All rights reserved.
//

#include "DisplacementFilter.h"

DisplacementFilter::DisplacementFilter(int bufferSize)
: _bufferSize(bufferSize), _positions(new iterable_queue<CGPoint>)
{
}

DisplacementFilter::~DisplacementFilter()
{
    delete _positions;
}

bool DisplacementFilter::validateDisplacement(CGPoint pos)
{
    _positions->push(pos);
    
    if (_positions->size() != _bufferSize) return false;
    
    double displacementRatioX = 0.0;
    double displacementRatioY = 0.0;
    for (auto it = _positions->begin() + 2; it != _positions->end(); it++) {
        displacementRatioX = (it->x - (it-1)->x) / ((_positions->begin()+1)->x - _positions->begin()->x);
        displacementRatioY = (it->y - (it-1)->y) / ((_positions->begin()+1)->y - _positions->begin()->y);
        _positions->pop();
        if (displacementRatioX > 1.0 || displacementRatioY > 1.0)
            return true;    // here we just think _bufferSize is 3, if more, need more complete algorithm to smooth the tracking
    }
    
    return false;
}

int DisplacementFilter::getBufferSize()
{
    return _bufferSize;
}

void DisplacementFilter::setBufferSize(int bufferSize)
{
    _bufferSize = bufferSize;
}