string pluginName = Meta::ExecutingPlugin().Name;
string outputFile = "dump";
bool isRecordingTimes = false;
bool windowVisible = false;


void RenderMenu() {
    if (UI::MenuItem("\\$66F" + Icons::FileTextO + "\\$z " + pluginName, "", windowVisible) && !windowVisible) {
        windowVisible = !windowVisible;
    }
}


void RenderInterface() {
    if (windowVisible) {
        UI::Begin(pluginName, windowVisible, UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize);
        UI::Text("Enter filename");
        outputFile = UI::InputText("Output Filename", outputFile);
        if (!isRecordingTimes && UI::Button("Start Recording")) {
            print("Recording match times to " + outputFile);
            isRecordingTimes = true;
        }
        if (isRecordingTimes && UI::Button("Stop Recording")) {
            print("Stopped recording match times");
            isRecordingTimes = false;
        }
        UI::End();
    }
}


void recordMatchTimes() {
    print("Winke!!");
}


void Main() {
    while (true) {
        if (isRecordingTimes) {
            recordMatchTimes();
        }
        sleep(1000);
    }
}
