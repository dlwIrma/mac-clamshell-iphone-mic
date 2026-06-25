# mac-clamshell-iphone-mic

Prefer Apple's iPhone Continuity Microphone only while a MacBook is in clamshell desktop mode.

只在 MacBook 合盖且连接外接显示器时，自动优先使用 Apple 连续互通里的 iPhone 麦克风；退出该状态后恢复原输入源。

## 中文说明

这个项目的初衷是解决 Apple 设备“连续互通”功能里的一个小问题：iPhone 已经作为连续互通麦克风出现在 macOS 里，但系统不一定会在合盖外接显示器时自动把输入源切过去。这个脚本只会在 MacBook 处于合盖外接显示器使用状态时，主动把输入源切到你配置的 iPhone 连续互通麦克风。

为什么需要外部麦克风：Apple 在 Platform Security 文档中说明，Apple silicon Mac 笔记本和带 T2 安全芯片的 Intel Mac 笔记本会在合盖时通过硬件断开麦克风，以防任何软件在合盖状态下使用内置麦克风。参考：[Hardware microphone disconnect](https://support.apple.com/guide/security/hardware-microphone-disconnect-secbbd20b00b/web)。

它主要针对 Apple Continuity / 连续互通的 iPhone Microphone。第三方麦克风如果能被 macOS 作为普通 CoreAudio 输入设备识别，并且有稳定 UID，理论上也可能可用，但这不是本项目的目标场景，也没有测试保证。

适合这样的场景：MacBook 合盖接外接显示器使用时，内置麦克风无法被系统使用，希望系统输入源自动切到某台 iPhone 的麦克风。

它的做法很简单：

- 每次运行时读取 macOS 的 `AppleClamshellState`。
- 同时检查是否存在在线显示器，避免没有外接显示器时切换。
- 只有在“合盖 + 至少一个在线显示器”的合盖桌面状态下，才用 `SwitchAudioSource` 按设备 UID 切到指定麦克风。
- 第一次进入该状态时保存当前输入源；一旦开盖、拔掉外接显示器，或不再满足这个状态，就恢复到之前的输入源。
- 如果电脑处于睡眠状态，LaunchAgent 通常不会运行；如果出现维护唤醒但没有在线显示器，脚本也不会切到 iPhone 麦克风。

它不会：

- 录音、监听或上传任何音频。
- 硬编码设备名或个人设备 UID。
- 无条件切回 MacBook 麦克风。默认会恢复进入合盖桌面状态前的输入源；你也可以配置固定恢复目标。
- 可靠地设置全局默认摄像头。macOS 的摄像头选择通常由 Zoom、Teams、浏览器等 App 自己维护，建议在对应 App 里选择 iPhone Camera。

### 安装依赖

```bash
brew install switchaudio-osx
```

### 找到 iPhone 麦克风 UID

```bash
/opt/homebrew/bin/SwitchAudioSource -a -t input -f json
```

在输出里找到你的 iPhone 麦克风，把 `uid` 复制下来。不要把自己的 UID 提交到公开仓库。

### 配置

```bash
mkdir -p ~/.config/clamshell-iphone-mic
cp config.example.sh ~/.config/clamshell-iphone-mic/config.sh
$EDITOR ~/.config/clamshell-iphone-mic/config.sh
```

把配置文件里的占位符改成你的 iPhone 麦克风 UID：

```bash
IPHONE_MIC_UID="PASTE_YOUR_IPHONE_MIC_UID_HERE"
```

默认情况下，脚本会在进入合盖桌面状态前自动保存当前输入源，并在退出时恢复它。如果你希望退出时总是恢复到某个固定麦克风，可以设置：

```bash
RESTORE_MIC_UID="PASTE_RESTORE_MIC_UID_HERE"
```

如果你的 Homebrew 安装在 Intel Mac 常见路径，可以把 `SWITCH_AUDIO_SOURCE` 改成 `/usr/local/bin/SwitchAudioSource`。

### 手动测试

```bash
./scripts/clamshell-iphone-mic.sh
```

查看当前输入源：

```bash
/opt/homebrew/bin/SwitchAudioSource -c -t input
```

查看合盖状态：

```bash
ioreg -r -k AppleClamshellState -d 4 | grep AppleClamshellState
```

`Yes` 表示合盖，`No` 表示开盖。

查看是否有在线显示器：

```bash
system_profiler SPDisplaysDataType -json | grep spdisplays_online
```

### 安装定时任务

默认每 10 秒执行一次：

```bash
./scripts/install-launch-agent.sh
```

自定义间隔，例如 30 秒：

```bash
INTERVAL=30 ./scripts/install-launch-agent.sh
```

卸载：

```bash
./scripts/uninstall-launch-agent.sh
```

## English

This project was created for a specific Apple Continuity issue: an iPhone is available to macOS as a Continuity Microphone, but macOS does not always automatically choose it when the MacBook is used with the lid closed and an external display. The script nudges the system input source to the configured iPhone Continuity Microphone only while the Mac is in clamshell desktop mode.

Why an external microphone is needed: Apple Platform Security documents that Apple silicon Mac laptops and Intel Mac laptops with the T2 Security Chip disconnect the microphone in hardware whenever the lid is closed, preventing any software from using the built-in microphone in that state. See: [Hardware microphone disconnect](https://support.apple.com/guide/security/hardware-microphone-disconnect-secbbd20b00b/web).

It is primarily intended for Apple's Continuity / iPhone Microphone feature. Third-party microphones may work if macOS exposes them as regular CoreAudio input devices with stable UIDs, but that is not the target use case and is not tested or guaranteed.

This tiny utility is for MacBook clamshell setups where the built-in microphone cannot be used with the lid closed and an iPhone Continuity Microphone is the preferred input device.

How it works:

- Reads macOS `AppleClamshellState`.
- Also checks for at least one online display, so it does not switch when no external display is available.
- Only in "lid closed + online display" clamshell desktop mode, switches the input microphone by stable device UID.
- Saves the current input device when entering that mode, then restores it when the lid opens, the external display disconnects, or the mode no longer applies.
- While the Mac is asleep, the LaunchAgent normally does not run. During maintenance wakes without an online display, the script will not switch to the iPhone microphone.

What it does not do:

- It does not record, monitor, or upload audio.
- It does not hard-code your device name or UID.
- It does not unconditionally switch back to the built-in MacBook microphone. By default it restores the input that was active before clamshell desktop mode; you may also configure a fixed restore target.
- It does not reliably set a global default camera. Camera choice on macOS is usually owned by each app, such as Zoom, Teams, or browsers. Pick your iPhone Camera inside the app.

### Requirements

```bash
brew install switchaudio-osx
```

### Find Your iPhone Microphone UID

```bash
/opt/homebrew/bin/SwitchAudioSource -a -t input -f json
```

Find your iPhone microphone in the output and copy its `uid`. Do not commit your personal UID to a public repository.

### Configure

```bash
mkdir -p ~/.config/clamshell-iphone-mic
cp config.example.sh ~/.config/clamshell-iphone-mic/config.sh
$EDITOR ~/.config/clamshell-iphone-mic/config.sh
```

Replace the placeholder:

```bash
IPHONE_MIC_UID="PASTE_YOUR_IPHONE_MIC_UID_HERE"
```

By default, the script saves the current input before it switches to the iPhone Continuity Microphone, then restores that input when leaving clamshell desktop mode. To always restore to a fixed microphone, set:

```bash
RESTORE_MIC_UID="PASTE_RESTORE_MIC_UID_HERE"
```

If Homebrew is installed under `/usr/local`, set `SWITCH_AUDIO_SOURCE` to `/usr/local/bin/SwitchAudioSource`.

### Test

```bash
./scripts/clamshell-iphone-mic.sh
```

Current input device:

```bash
/opt/homebrew/bin/SwitchAudioSource -c -t input
```

Lid state:

```bash
ioreg -r -k AppleClamshellState -d 4 | grep AppleClamshellState
```

`Yes` means closed. `No` means open.

Online displays:

```bash
system_profiler SPDisplaysDataType -json | grep spdisplays_online
```

### Install the LaunchAgent

Run every 10 seconds:

```bash
./scripts/install-launch-agent.sh
```

Use a custom interval:

```bash
INTERVAL=30 ./scripts/install-launch-agent.sh
```

Uninstall:

```bash
./scripts/uninstall-launch-agent.sh
```

## License

MIT
