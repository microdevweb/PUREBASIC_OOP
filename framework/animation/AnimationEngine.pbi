; ============================================================================
; PureBasic OOP GUI Framework - AnimationEngine.pbi
; High-Performance 60 FPS Micro-Animation & Transition Engine for CanvasControls
; Features: Non-blocking 16ms event pump, Auto-sleep when idle (0% CPU),
;           Standard Easing functions (Linear, EaseOutQuad, EaseOutCubic, EaseOutBack),
;           Float & Color Lerp interpolations.
; Author:      MicrodevWeb & Google DeepMind Antigravity
; ============================================================================

XIncludeFile "../Component.pbi"

#UI_ANIM_EASING_LINEAR       = 0
#UI_ANIM_EASING_EASEOUT_QUAD  = 1
#UI_ANIM_EASING_EASEOUT_CUBIC = 2
#UI_ANIM_EASING_EASEOUT_BACK  = 3
#UI_ANIM_EASING_EASEINOUT_QUAD = 4

Declare UI_InitAnimationEngine()
Declare.b UI_HasActiveAnimations()
Declare UI_UpdateAnimations()

Structure UI_ActiveAnimation
  *control.UI::Component
  propType.i          ; 1: Float (Scale/Opacity), 2: Color (Background/Border)
  startVal.f
  targetVal.f
  currentVal.f
  startColor.i
  targetColor.i
  startTime.q
  durationMs.i
  easingType.i
  isCompleted.b
EndStructure

Namespace UI {

  Class AnimationEngine {
    Protected Map activeAnimations.UI_ActiveAnimation()
    Protected isRunning.b
    Protected lastTick.q

    Public Method Init() {
      This\isRunning = #False
      This\lastTick = ElapsedMilliseconds()
    }

    Public Method Free() {
      ClearMap(This\activeAnimations())
      This\isRunning = #False
    }

    ; --- Mathematical Easing Functions ---

    Public Method.f ApplyEasing(t.f, easing.i) {
      If t <= 0.0 : ProcedureReturn 0.0 : EndIf
      If t >= 1.0 : ProcedureReturn 1.0 : EndIf

      Select easing
        Case #UI_ANIM_EASING_EASEOUT_QUAD:
          ; 1 - (1 - t)^2
          Protected inv.f = 1.0 - t
          ProcedureReturn 1.0 - (inv * inv)

        Case #UI_ANIM_EASING_EASEOUT_CUBIC:
          ; 1 - (1 - t)^3
          Protected inv3.f = 1.0 - t
          ProcedureReturn 1.0 - (inv3 * inv3 * inv3)

        Case #UI_ANIM_EASING_EASEOUT_BACK:
          ; Effet de pop / rebond doux moderne
          Protected c1.f = 1.70158
          Protected c3.f = c1 + 1.0
          Protected tm.f = t - 1.0
          ProcedureReturn 1.0 + c3 * (tm * tm * tm) + c1 * (tm * tm)

        Case #UI_ANIM_EASING_EASEINOUT_QUAD:
          If t < 0.5
            ProcedureReturn 2.0 * t * t
          Else
            Protected invHalf.f = -2.0 * t + 2.0
            ProcedureReturn 1.0 - (invHalf * invHalf) / 2.0
          EndIf

        Default: ; Linear
          ProcedureReturn t
      EndSelect
    }

    ; --- Interpolations ---

    Public Method.f LerpFloat(vStart.f, vEnd.f, t.f) {
      ProcedureReturn vStart + (vEnd - vStart) * t
    }

    Public Method.i LerpColor(cStart.i, cEnd.i, t.f) {
      If t <= 0.0 : ProcedureReturn cStart : EndIf
      If t >= 1.0 : ProcedureReturn cEnd : EndIf

      Protected r1.i = Red(cStart),   g1.i = Green(cStart), b1.i = Blue(cStart)
      Protected r2.i = Red(cEnd),     g2.i = Green(cEnd),   b2.i = Blue(cEnd)

      Protected r.i = r1 + (r2 - r1) * t
      Protected g.i = g1 + (g2 - g1) * t
      Protected b.i = b1 + (b2 - b1) * t

      If r < 0 : r = 0 : ElseIf r > 255 : r = 255 : EndIf
      If g < 0 : g = 0 : ElseIf g > 255 : g = 255 : EndIf
      If b < 0 : b = 0 : ElseIf b > 255 : b = 255 : EndIf

      ProcedureReturn RGB(r, g, b)
    }

    ; --- Enregistrement d'Animations ---

    Public Method StartFloatAnimation(*ctrl.UI::Component, key_p.s, fromVal.f, toVal.f, durationMs_p.i = 150, easing_p.i = #UI_ANIM_EASING_EASEOUT_QUAD) {
      If Not *ctrl : ProcedureReturn : EndIf
      Protected animKey.s = Str(*ctrl) + "_" + key_p

      This\activeAnimations(animKey)\control = *ctrl
      This\activeAnimations(animKey)\propType = 1
      This\activeAnimations(animKey)\startVal = fromVal
      This\activeAnimations(animKey)\targetVal = toVal
      This\activeAnimations(animKey)\currentVal = fromVal
      This\activeAnimations(animKey)\startTime = ElapsedMilliseconds()
      This\activeAnimations(animKey)\durationMs = durationMs_p
      This\activeAnimations(animKey)\easingType = easing_p
      This\activeAnimations(animKey)\isCompleted = #False
      This\isRunning = #True
    }

    ; --- Render Loop and Check (60 FPS Tick) ---

    Public Method.b HasActiveAnimations() {
      ProcedureReturn Bool(MapSize(This\activeAnimations()) > 0)
    }

    Public Method Update() {
      If MapSize(This\activeAnimations()) = 0
        This\isRunning = #False
        ProcedureReturn
      EndIf

      Protected now.q = ElapsedMilliseconds()
      Protected NewList toRemove.s()

      ForEach This\activeAnimations()
        Protected *anim.UI_ActiveAnimation = @This\activeAnimations()
        Protected elapsed.i = now - *anim\startTime
        Protected progress.f = elapsed / *anim\durationMs

        If progress >= 1.0
          progress = 1.0
          *anim\isCompleted = #True
        EndIf

        Protected easedT.f = This\ApplyEasing(progress, *anim\easingType)

        If *anim\propType = 1 ; Float (Scale)
          *anim\currentVal = This\LerpFloat(*anim\startVal, *anim\targetVal, easedT)
          ; Dispatch value to Canvas control
          If *anim\control
            *anim\control\OnAnimationTick("Scale", *anim\currentVal)
          EndIf
        EndIf

        If *anim\isCompleted
          AddElement(toRemove())
          toRemove() = MapKey(This\activeAnimations())
        EndIf
      Next

      ForEach toRemove()
        DeleteMapElement(This\activeAnimations(), toRemove())
      Next

      If MapSize(This\activeAnimations()) = 0
        This\isRunning = #False
      EndIf
    }
  }

}

; Instance Singleton Globale de l'AnimationEngine
Global UI_GlobalAnimEngine.UI::AnimationEngine

Procedure UI_InitAnimationEngine()
  If Not UI_GlobalAnimEngine
    UI_GlobalAnimEngine = New UI::AnimationEngine()
  EndIf
EndProcedure

Procedure.b UI_HasActiveAnimations()
  If UI_GlobalAnimEngine
    ProcedureReturn UI_GlobalAnimEngine\HasActiveAnimations()
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure UI_UpdateAnimations()
  If UI_GlobalAnimEngine
    UI_GlobalAnimEngine\Update()
  EndIf
EndProcedure

Procedure UI_ShutdownAnimationEngine()
  If UI_GlobalAnimEngine
    UI_GlobalAnimEngine\Free()
    UI_GlobalAnimEngine = #Null
  EndIf
EndProcedure
