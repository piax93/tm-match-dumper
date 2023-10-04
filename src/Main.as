// Just for ease of access
const string pluginName = Meta::ExecutingPlugin().Name;

// UI toggles
bool isRecordingTimes = false;
bool windowVisible = false;

// Global state
string outputFile = "dump";
string currentMap = "";
dictionary trackedPlayers = dictionary();
MatchDump@ dumper;


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
            @dumper = MatchDump(outputFile);
            isRecordingTimes = true;
        }
        if (isRecordingTimes && UI::Button("Stop Recording")) {
            print("Stopped recording match times");
            isRecordingTimes = false;
            currentMap = "";
            trackedPlayers.DeleteAll();
            dumper.close();
        }
        UI::End();
    }
}


void recordMatchTimes() {
    // Double check recording is enabled
    if (dumper is null || dumper.isClosed()) return;

    // Check we are gaming
    auto app = cast<CTrackMania>(GetApp());
    if (app.CurrentPlayground is null || (app.CurrentPlayground.UIConfigs.Length < 1)) return;

    // If we changed track, let's clear player tracking
    auto mapName = StripFormatCodes(app.RootMap.MapName);
    if (currentMap != mapName) {
        trackedPlayers.DeleteAll();
        currentMap = mapName;
    }

    // Fetch player data
    auto mlf = MLFeed::GetRaceData_V4();
    for (uint i = 0; i < mlf.SortedPlayers_Race.Length; i++) {
        auto player = cast<MLFeed::PlayerCpInfo_V4>(mlf.SortedPlayers_Race[i]);
        bool alreadyTracked = trackedPlayers.Exists(player.WebServicesUserId);

        // New finish for the player, we store it
        if (player.IsFinished && !alreadyTracked) {
            print("Recording time for " + player.Name);
            dumper.addEntry(mapName, player.WebServicesUserId, player.Name, player.LastCpTime);
            trackedPlayers.Set(player.WebServicesUserId, 1);
            continue;
        }

        // Player was tracked, but has not finished, meaning they started a new round, so we "untrack" them
        if (!player.IsFinished && alreadyTracked) {
            trackedPlayers.Delete(player.WebServicesUserId);
        }
    }
}


void Main() {
    DepCheck();
    while (true) {
        if (isRecordingTimes) {
            recordMatchTimes();
        }
        sleep(1000);
    }
}
