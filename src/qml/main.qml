import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import "strings.js" as S

PageStackWindow {
    id: appWindow

    showStatusBar: true
    initialPage: MainPage { id: mainPage }

    // header colours from the icon (Lyrion greens)
    property color headerTop: "#7da469"
    property color headerBottom: "#3f5c33"
    property color accent: theme.inverted ? "#a1be91" : "#4f7a3e"

    function showBanner(text) {
        banner.text = text;
        banner.show();
    }

    InfoBanner {
        id: banner
        y: 36 + 8
    }

    // Audio player in its own file: if the Qt Mobility multimedia module is
    // missing, only reading aloud is lost, not the whole app.
    Loader {
        id: playerLoader
        source: "Player.qml"
    }
    property bool canSpeak: playerLoader.status == Loader.Ready
    property bool speaking: canSpeak && playerLoader.item.busy

    function speak(text, lang) {
        if (!net.online())
            showBanner(S.t(uiLang, "noInternet"));
        else if (canSpeak)
            playerLoader.item.speak(text, lang);
    }
    function stopSpeaking() {
        if (canSpeak)
            playerLoader.item.stop();
    }

    Component.onCompleted: {
        theme.colorScheme = 4;      // green highlights (switches, buttons, lists)
        theme.inverted = settings.get("darkTheme", "false") == "true";
    }
}
