# mac-clamshell-iphone-mic

Automatically prefer an iPhone Continuity Microphone when a MacBook is in clamshell mode.

合盖时自动优先使用 iPhone 连续互通麦克风；开盖时不改动当前输入源。

## 中文说明

这个小工具适合这样的场景：MacBook 合盖接外接显示器使用时，内置麦克风位置不理想，希望系统输入源自动切到某台 iPhone 的麦克风。

它的做法很简单：

- 每次运行时读取 macOS 的 `AppleClamshellState`。
- 如果 MacBook 处于合盖状态，就用 `SwitchAudioSource` 按设备 UID 切到指定麦克风。
- 如果 MacBook 是开盖状态，脚本直接退出，不切换任何设备。

它不会：

- 录音、监听或上传任何音频。
- 硬编码设备名或个人设备 UID。
- 在开盖状态下自动切回 MacBook 麦克风。
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

This tiny utility is for MacBook clamshell setups where the built-in microphone is poorly positioned and an iPhone Continuity Microphone is the better input device.

How it works:

- Reads macOS `AppleClamshellState`.
- When the lid is closed, switches the input microphone by stable device UID.
- When the lid is open, exits without changing the current input device.

What it does not do:

- It does not record, monitor, or upload audio.
- It does not hard-code your device name or UID.
- It does not switch back to the built-in MacBook microphone when the lid opens.
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
