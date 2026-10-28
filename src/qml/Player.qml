import QtQuick 1.1
import QtMultimediaKit 1.1
import "strings.js" as S

// Reads text aloud: main.py downloads Google speech as MP3 pieces,
// this plays them one after another.
Item {
    id: player
    property bool busy: false
    property variant files: []
    property int index: 0

    function speak(text, lang) {
        stop();
        busy = true;
        speech.speak(text, lang);
    }
    function stop() {
        speech.stop();
        audio.stop();
        busy = false;
        files = [];
    }
    function playIndex(i) {
        if (i >= files.length) {
            busy = false;
            return;
        }
        index = i;
        audio.source = "";
        audio.source = "file://" + files[i];
        audio.play();
    }

    Audio {
        id: audio
        onError: {
            player.busy = false;
            appWindow.showBanner(S.t(uiLang, "speakError"));
        }
        onStatusChanged: {
            if (status == Audio.EndOfMedia)
                player.playIndex(player.index + 1);
            else if (status == Audio.InvalidMedia) {
                player.busy = false;
                appWindow.showBanner(S.t(uiLang, "speakError"));
            }
        }
    }

    Connections {
        target: speech
        onReady: {
            player.files = JSON.parse(speech.takeFiles());
            if (player.files.length == 0)
                player.busy = false;
            else
                player.playIndex(0);
        }
        onFailed: {
            player.busy = false;
            appWindow.showBanner(S.t(uiLang, "speakError"));
        }
    }
}
