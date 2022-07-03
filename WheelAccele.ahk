;**********************************************************************
;* プログラム名  ：WheelAccele（WheelAccele.ahk）                     *
;* プログラム概要：加速スクロール                                     *
;*                 スクロールすればするほど速くなります               *
;* 依存関係      ：なし                                               *
;**********************************************************************

;---------------------
; AutoHotKey設定      
;---------------------
#InstallKeybdHook
#UseHook
#SingleInstance force
#MaxHotkeysPerInterval 1000

;---------------------
; キーの設定          
;---------------------
KeySetting:

    WheelUp::AcceleScroll()
    WheelDown::AcceleScroll()
    
return

;**********************************************************************
;* 処理概要：加速スクロール                                           *
;* 処理説明：スクロールをするたびに加速する                           *
;* 引数    ：なし                                                     *
;* 返り値  ：なし                                                     *
;**********************************************************************
AcceleScroll() 
{

    ; 加速率を取得
    delta := AS_Throttle()
    
    ;ホイールのタイプを取得（UpなのかDownなのか）
    wheeltype := A_ThisHotkey
    
    ;加速スクロールの実行
    MouseClick, %wheeltype%, , , %delta%

}

;----------------------------------------------------------
; 加速率を線形補間で計算する
; 	minThrottle   = 最小加速率
; 	maxThrottle   = 最大加速率
; 	minWheelSpeed = 最小加速率になるホイール回転速度 (ノッチ/秒)
; 	maxWheelSpeed = 最大加速率になるホイール回転速度 (ノッチ/秒)
; 	EW_Debug      = デバッグモード
;----------------------------------------------------------
AS_Throttle()
{
    
    ;-------------------------------------------------------
    ; オプション（お好みで変更して下さい）
    ; 参照：http://mobitan.org/ahk/WheelAccel.txt
    ;-------------------------------------------------------
    minThrottle      := 2  ; 最小加速率
    maxThrottle      := 7  ; 最大加速率
    minWheelSpeed    := 5  ; 最小加速率になるホイール回転速度 (ノッチ/秒)
    maxWheelSpeed    := 30 ; 最大加速率になるホイール回転速度 (ノッチ/秒)
    
    static prevspd := 0
    
    if (A_PriorHotkey <> A_ThisHotkey || A_TimeSincePriorHotkey > 250) {
    
        prevspd := 0
        nextspd := 0
        
    } else {
    
        ; 現在のホイール回転速度 (ノッチ/秒)を取得
        nextspd := 1000 / A_TimeSincePriorHotkey 
        
    }
    
    ; 直近 2 ノッチの平均回転速度 (ノッチ/秒)を取得
    spd := (prevspd + nextspd) / 2 
    
    if (spd < minWheelSpeed) {
    
        thr := 1
        
    } else {
    
        thr := floor((spd - minWheelSpeed) * (maxThrottle - minThrottle) / (maxWheelSpeed - minWheelSpeed) + minThrottle)
        
    }
    
    if (thr > maxThrottle) {
    
        thr := maxThrottle
        
    }

    prevspd := nextspd
    return thr
    
}
