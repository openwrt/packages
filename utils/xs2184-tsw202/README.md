# XS2184 PSE driver and monitor app

## 检测原理
- 正常工作时, PSE 协商使能, 供电给 PD, 并统计15轮 实时功耗;
- 当平均功耗 为0, 判定 PD 出现异常, 关闭 PSE 对应 Port的供电;
- 被关闭的 Port, 在下一轮统计时, 重新开启协商供电使能;
- 实测, MS1800K 在 上电复位异常情况下, 实时功耗 为0 mW, 能被识别出异常, 并断电重启;

## 测试方法
1. 正常 PoE - PD 组网;
2. 后台执行:  xs2184 -m 1000;
3. xs2184 监听模式, 参数 -m: monitor 模式, 检测间隔 1000ms, 平均功耗计算周期: 默认 15 轮, -s <ms> 可修改;
4. 观察 xs2184 日志, 会实时打印功耗和检测状态;
5. 用镊子短路 MS1800K 的 C133 复位电容, 模拟上电无法启动的情况;
6. 重复4), 对比关电和重新上电的行为, 以及MS1800K重新开机和功耗变化;

## Funktionsprinzip
- Im Normalbetrieb verhandelt die PSE die Freigabe, versorgt das PD mit Strom und zeichnet den Stromverbrauch in Echtzeit über 15 Zyklen auf.
- Wenn der durchschnittliche Stromverbrauch Null erreicht, wird das PD als fehlerhaft eingestuft und die PSE unterbricht die Stromversorgung des entsprechenden Ports.
- Der deaktivierte Port verhandelt während des nächsten Verbrauchszyklus erneut die Freigabe der Stromversorgung.
- Feldtests bestätigen, dass der MS1800K unter abnormalen Power-On-Reset-Bedingungen einen Echtzeit-Stromverbrauch von null mW aufweist, was die Erkennung von Anomalien und den anschließenden Neustart nach dem Ausschalten ermöglicht.

## Testmethodik
1. Standard-PoE-PD-Netzwerkkonfiguration.
2. Hintergrundausführung: xs2184 -m 1000.
3. xs2184-Überwachungsmodus, Parameter -m: Überwachungsmodus, Erkennungsintervall 1000 ms, durchschnittlicher Stromverbrauchsberechnungszyklus: standardmäßig 15 Runden, änderbar mit -s in ms;
4. Beobachten Sie die xs2184-Protokolle, die den Stromverbrauch und den Erkennungsstatus in Echtzeit anzeigen.
5. Verwenden Sie eine Pinzette, um den C133-Reset-Kondensator des MS1800K kurzzuschließen und so einen Fehler beim Hochfahren nach dem Einschalten zu simulieren.
6. Wiederholen Sie Schritt 4 und vergleichen Sie das Verhalten nach dem Ausschalten und erneuten Einschalten mit dem Neustart des MS1800K und den Änderungen des Stromverbrauchs.

## UI einfach
```
uci add luci command
uci set luci.@command[-1].name="poe-status"
uci set luci.@command[-1].command="xs2184 -c"
last=8
for i in $(seq 1 $last);do
uci add luci command
uci set luci.@command[-1].name="poe-lan$i-on"
uci set luci.@command[-1].command="xs2184 -u $last"
uci add luci command
uci set luci.@command[-1].name="poe-lan$i-off"
uci set luci.@command[-1].command="xs2184 -d $last"
last=$((last-1))
done
uci commit luci
```
