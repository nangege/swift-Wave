//
//  Waver.swift
//  Swift-Waver
//
//  Created by nangezao on 14/12/21.
//  Copyright (c) 2014年 dreamer.nange. All rights reserved.
//

import UIKit

public class Wave: UIView {
    
    public var frequency:CGFloat     = 1.2
    public var amplitude:CGFloat     = 1.0
    public var idleAmplitude:CGFloat = 0.01

    public var phaseShift:CGFloat    = -0.25
    public var density:CGFloat       = 1.0
    public var numOfWavers           = 5
    
    public var mainWaveWidth         = 2.0
    public var decorativeWavesWidth  = 2.0

    public var waveColor             = UIColor.whiteColor()
    
    private var waverHeight:CGFloat  = 0
    private var waverWidth:CGFloat   = 0
    private var phase:CGFloat        = 0.0
    private var wavers:Array<CAShapeLayer> = []
    


    private var waverCallBack:() ->() = {return}
    
    private var waveMid:CGFloat{
        get{
            return waverWidth/2.0
        }
    }
    private var maxAmplitude:CGFloat{
        get{
            return waverHeight - 4.0
        }
    }
    
    public var level:CGFloat{
        set{
            phase = phase + phaseShift; // Move the wave
            amplitude = max( newValue,idleAmplitude);
            updateMeters();
        }
        get{
            return 0.1;
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        waverWidth  = 0.98*CGRectGetWidth(frame)
        waverHeight = CGRectGetHeight(frame)
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setWaverLevelCallback(callBack:()->()){
        waverCallBack = callBack
        
        for var i = 0; i < self.numOfWavers; i++ {
            let waveline = CAShapeLayer();
            waveline.lineCap       = kCALineCapButt;
            waveline.lineJoin      = kCALineJoinRound;
            waveline.strokeColor   = UIColor.clearColor().CGColor
            waveline.fillColor     = UIColor.clearColor().CGColor
            let lineWidth =   (i == 0) ? mainWaveWidth : decorativeWavesWidth;
            waveline.lineWidth = CGFloat(lineWidth)
            let progress = 1.0 - CGFloat(i)/CGFloat(numOfWavers);
            let multiplier = min(CGFloat(1.0), CGFloat((progress / 3.0 * 2.0) + (1.0 / 3.0)));
            waveline.strokeColor   = UIColor(white: 1.0, alpha:( (i == 0) ? 1.0 : 1.0 * multiplier * 0.4)).CGColor;
            self.layer.addSublayer(waveline);
            wavers.append(waveline)
        }

        let displaylink = CADisplayLink(target:self, selector:"warverExecute")
        displaylink.addToRunLoop(NSRunLoop.currentRunLoop() ,forMode:NSRunLoopCommonModes)
    }
    
    func warverExecute(){
        waverCallBack()
    }
    
    
    func updateMeters(){
        UIGraphicsBeginImageContext(self.frame.size)
        
        for i in 0...numOfWavers - 1{
            let wavelinePath = UIBezierPath()
            let progress = 1.0 - CGFloat(i)/CGFloat( self.numOfWavers);
            let normedAmplitude:CGFloat = (1.5 * progress - 0.5) * CGFloat(self.amplitude);
            for var x:CGFloat = 0.0; x < self.waverWidth + self.density;x += self.density{
                
                let scaling = -pow(x / self.waveMid  - 1, 2) + 1;                             // make center bigger
                
                let sinValue = sin(( CGFloat(M_PI*2.0)*(x / self.waverWidth) * self.frequency + self.phase))
                
                let y = scaling * self.maxAmplitude * normedAmplitude * sinValue + self.waverHeight;
                
                if x == 0 {
                    wavelinePath.moveToPoint(CGPointMake(x, y))
                }
                else {
                    wavelinePath.addLineToPoint(CGPointMake(x, y))
                }
            }
            let waveline = self.wavers[i];
            waveline.path = wavelinePath.CGPath;
        }
        
        UIGraphicsEndImageContext()
    }

}
