global stickThreshold := 50 * 0.1
global lStickState := 0
global rStickState := 0

global screenCenterX := A_ScreenWidth / 2
global screenCenterY := A_ScreenHeight / 2

global startPosX := screenCenterX
global startPosY := screenCenterY - (screenCenterY * 0.1)
global mousePosMulti := 1

global mode := "constrain"

global cross_held := 0

; Main loop
Loop {
  ResetMousePosMulti()

  FaceButtons()

  LeftAnalog()
  RightAnalog()

  Sleep 1
}

AnalogStickToMousePos(x, y, mult) {
  MouseX := StartPosX + (x * MousePosMulti * mult)
  MouseY := StartPosY + (y * MousePosMulti * mult)

  MouseMove, MouseX, MouseY, 0
}

AnalogStickMoveMouse(x, y, mult) {
  MouseGetPos, MouseX, MouseY
  MouseMove, MouseX + (x * mult), MouseY + (y * mult), 0
}

ResetMousePosMulti() {
  mousePosMulti := 1
}

SetMousePosMulti(value) {
  mousePosMulti := value
}

LeftAnalog(){
  ; left analog axis
  x := GetKeyState("1JoyX") - 50
  y := GetKeyState("1JoyY") - 50

  ; hold down middle mouse if over threshold, and if right stick is not in use
  if ((abs(x) > stickThreshold || abs(y) > stickThreshold) && rStickState != 1){
    if(mode == "constrain") {
      AnalogStickToMousePos(x, y, 5)
      ; send mouse down once at start of move
      if(lStickState != 1){
        Send, {MButton down}
        OutputDebug, %A_Now%: Left analog button down.
      }
    }
    if(mode == "free") {
      AnalogStickMoveMouse(x, y, 0.5)
    }
    lStickState := 1
  }
  if(abs(x) < stickThreshold && abs(y) < stickThreshold && lStickState == 1){
    if(mode == "constrain") {
      ; send mouse up when stick returns to center
      Send, {MButton up}
      OutputDebug, %A_Now%: Left analog button up.
    }
    lStickState := 0
  }
}


RightAnalog(){
  ; right analog axis
  u := GetKeyState("1JoyU") - 50
  r := GetKeyState("1JoyR") - 50

  ; hold down right click if over threshold else let it go
  if ((abs(u) > stickThreshold || abs(r) > stickThreshold)){
    if(mode == "constrain"){
      AnalogStickToMousePos(u, r, 15)

      ; send mouse down once at start of move
      if(rStickState != 1){
        Send, {RButton down}
        OutputDebug, %A_Now%: Right analog button down.
      }
    }
    if(mode == "free"){
      AnalogStickMoveMouse(u, r, 1)
    }
    rStickState := 1
  }
  if(abs(r) < stickThreshold && abs(u) < stickThreshold && rStickState == 1){
    if(mode == "constrain") {
      ; send mouse up when stick returns to center
      Send, {RButton up}
      OutputDebug, %A_Now%: Right analog button up.
    }
    rStickState := 0
  }

}

FaceButtons() {
  ; button status
  cross := GetKeyState("1Joy1")
  circle  := GetKeyState("1Joy2")
  square := GetKeyState("1Joy3")
  triangle := GetKeyState("1Joy4")

  if(cross){
    SetMousePosMulti(1)
  }
  if(square){
    SetMousePosMulti(1)
  }
  if(triangle){
    SetMousePosMulti(1)
  }
  if(circle){
    SetMousePosMulti(1)
  }
}

ToggleMode() {
  Send, {MButton up}
  Send, {RButton up}
  
  if(mode == "free") {
    mode := "constrain"
  }
  else {
    mode := "free"
  }
}

; Key bindings
1Joy10::
  ToggleMode()
return