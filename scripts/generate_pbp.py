import os
import hashlib

base_dir = r'c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE'

primary_files = [
    'tests\\demo_wpf_styles.pb',
    'tests\\demo_wpf_styles.xml',
    'tests\\demo_canvas_xml.pb',
    'tests\\demo_canvas_xml.xml',
]

core_files = [
    'framework\\UI.pbi',
    'framework\\Component.pbi',
    'framework\\Gadget.pbi',
    'framework\\Window.pbi',
    'framework\\Application.pbi',
    'framework\\CanvasControl.pbi',
    'framework\\CustomGadget.pbi',
    'framework\\XMLLoader.pbi',
    'framework\\animation\\AnimationEngine.pbi',
    'framework\\style\\Style.pbi',
    'framework\\style\\ResourceDictionary.pbi',
    'framework\\controls\\CanvasButton.pbi',
    'framework\\controls\\CanvasText.pbi',
    'framework\\controls\\CanvasTextBox.pbi',
    'framework\\controls\\CanvasTree.pbi',
    'framework\\controls\\Canvas.pbi',
    'framework\\layout\\Container.pbi',
    'framework\\layout\\StackPanel.pbi',
    'framework\\layout\\DockPanel.pbi',
    'framework\\layout\\Grid.pbi',
    'framework\\controls\\Button.pbi',
    'framework\\controls\\TextBox.pbi',
    'framework\\controls\\Label.pbi',
    'framework\\controls\\CheckBox.pbi',
    'framework\\controls\\RadioButton.pbi',
    'framework\\controls\\ProgressBar.pbi',
    'framework\\controls\\Slider.pbi',
    'framework\\controls\\ComboBox.pbi',
    'framework\\controls\\SpinBox.pbi',
    'framework\\controls\\Editor.pbi',
    'framework\\controls\\ListView.pbi',
    'framework\\controls\\TreeView.pbi',
    'framework\\controls\\DatePicker.pbi',
    'framework\\controls\\GroupBox.pbi',
    'framework\\controls\\TabControl.pbi',
    'framework\\controls\\ToggleSwitch.pbi',
    'framework\\controls\\ListIcon.pbi',
    'framework\\mvvm\\MVVM.pbi',
    'framework\\mvvm\\ObservableObject.pbi',
    'framework\\mvvm\\ObservableCollection.pbi',
    'framework\\mvvm\\Property.pbi',
    'framework\\mvvm\\RelayCommand.pbi',
    'framework\\mvvm\\ViewModelBase.pbi',
    'framework\\mvvm\\BindingEngine.pbi',
]

all_files = primary_files + core_files

lines = []
lines.append('<?xml version="1.0" encoding="UTF-8"?>')
lines.append('')
lines.append('<project xmlns="http://www.purebasic.com/namespace" version="1.0" creator="PureBasic 6.40 (Windows - x64)">')
lines.append('  <section name="config">')
lines.append('    <options closefiles="1" openmode="0" name="PureBasic WPF CanvasControl Studio"/>')
lines.append('  </section>')
lines.append('  <section name="data">')
lines.append('    <explorer view="tests\\" pattern="0"/>')
lines.append('    <log show="1"/>')
lines.append('    <lastopen date="2026-09-08 10:35" user="u237685" host="CSL0111"/>')
lines.append('  </section>')
lines.append('  <section name="files">')

for i, rel in enumerate(all_files, 1):
    full = os.path.join(base_dir, rel)
    with open(full, 'rb') as f:
        md5 = hashlib.md5(f.read()).hexdigest()
    lastopen = '1' if i <= 2 else '0'
    lines.append(f'    <file name="{rel}">')
    lines.append(f'      <config load="0" scan="1" panel="1" warn="1" lastopen="{lastopen}" sortindex="{i}" panelstate="++"/>')
    lines.append(f'      <fingerprint md5="{md5}"/>')
    lines.append('    </file>')

lines.append('  </section>')
lines.append('  <section name="targets">')
lines.append('    <target name="Cible par défaut" enabled="1" default="1">')
lines.append('      <inputfile value="tests\\demo_wpf_styles.pb"/>')
lines.append('      <outputfile value="tests\\demo_wpf_styles.exe"/>')
lines.append('      <options xpskin="1" dpiaware="1" debug="1" thread="1" optimizer="0"/>')
lines.append('    </target>')
lines.append('  </section>')
lines.append('</project>')
lines.append('')

pbp_path = os.path.join(base_dir, 'demo_wpf_styles.pbp')
with open(pbp_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))

print(f'Successfully generated {pbp_path} with {len(all_files)} files.')
