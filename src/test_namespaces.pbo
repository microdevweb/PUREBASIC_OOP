; ============================================================================
; Test PureBasic OOP : Hierarchical Namespaces, Using & Aliases
; ============================================================================

Namespace Game::Graphics
  Class Renderer
    Protected width.i
    Protected height.i
    
    Public Method Init(w.i, h.i)
      This\width = w
      This\height = h
    EndMethod
    
    Public Method Render()
      PrintN("[GFX Renderer] Rendering frame at " + Str(This\width) + "x" + Str(This\height))
    EndMethod
  EndClass
EndNamespace

Namespace Game::Audio
  Class SoundSystem
    Protected volume.i
    
    Public Method Init(vol.i)
      This\volume = vol
    EndMethod
    
    Public Method Play(soundName.s)
      PrintN("[Audio Engine] Playing '" + soundName + "' at volume " + Str(This\volume) + "%")
    EndMethod
  EndClass
EndNamespace

; Namespace Alias: GFX -> Game::Graphics
Namespace GFX = Game::Graphics

; Using Directive: Import Game::Audio
Using Game::Audio

OpenConsole()
PrintN("=== Test Namespaces, Using & Aliases ===")

; 1. Using fully qualified name
Define *ren1.Game::Graphics::Renderer = New Game::Graphics::Renderer(1920, 1080)
*ren1\Render()

; 2. Using Namespace Alias (GFX::Renderer)
Define *ren2.GFX::Renderer = New GFX::Renderer(800, 600)
*ren2\Render()

; 3. Using imported namespace via 'Using Game::Audio'
Define *audio.SoundSystem = New SoundSystem(85)
*audio\Play("intro.wav")

PrintN("=== End of Namespaces Test ===")
PrintN("")
PrintN("Appuyez sur Entree pour quitter...")
Input()
CloseConsole()
