// Just for ease of access
const string pluginName = Meta::ExecutingPlugin().Name;

// Settings
[Setting name="Polling Rate Milliseconds" description="How often the plugin checks for players crossing the finish line"]
int dataPollingRateMs = 1000;

// UI toggles
bool isRecordingTimes = false;
bool windowVisible = false;
bool skipWarmups = true;
bool recordScoredPoints = false;
bool recordEveryCheckpoint = false;
bool assignRoundIds = false;

// Global state
uint roundNumber = 0;
string roundId = "";
bool recentlyRecordedTime = false;
string outputFile = "dump";
string currentMap = "";
Knowledge currentMapMultilap = Knowledge::UNSURE;
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
        UI::Text("Enter Filename");
        outputFile = UI::InputText("##", outputFile);
        skipWarmups = UI::Checkbox("Skip warm-ups", skipWarmups);
        recordScoredPoints = UI::Checkbox("Record points scored by player", recordScoredPoints);
        recordEveryCheckpoint = UI::Checkbox("Record Every Checkpoint", recordEveryCheckpoint);
        assignRoundIds = UI::Checkbox("Assign Unique Round IDs", assignRoundIds);
        UI::BeginGroup();
        if (!isRecordingTimes && UI::Button("Start Recording")) {
            print("Recording match times to " + outputFile);
            @dumper = MatchDump(outputFile, recordScoredPoints, recordEveryCheckpoint, assignRoundIds);
            isRecordingTimes = true;
        }
        if (isRecordingTimes && UI::Button("Stop Recording")) {
            print("Stopped recording match times");
            isRecordingTimes = false;
            recentlyRecordedTime = false;
            roundNumber = 0;
            currentMap = "";
            trackedPlayers.DeleteAll();
            dumper.close();
        }
        UI::SameLine();
        if (UI::Button("Open Folder")) {
            OpenExplorerPath(IO::FromStorageFolder(""));
        }
        UI::EndGroup();
        UI::End();
    }
}


void updateRoundNumber(uint n) {
    roundNumber = n;
    if (assignRoundIds) {
        roundId = GenerateRoundId();
    }
}


void recordMatchTimes() {
    // Double check recording is enabled
    if (dumper is null || dumper.isClosed()) return;

    // Check we are gaming and load some stuff
    auto app = cast<CTrackMania>(GetApp());
    if (app.CurrentPlayground is null || (app.CurrentPlayground.UIConfigs.Length < 1)) return;

    // Check if in warmup and skip if we have to
    if (skipWarmups && IsInWarmup(app)) return;

    if (roundNumber > 0) {
        // Reset rounds number in warmups
        if (IsInWarmup(app)) updateRoundNumber(0);
    } else {
        // If recording start mid-match, set round number to sum of teams scores
        updateRoundNumber(GetTotalServerScore(app));
    }

    // If we changed track, let's clear player tracking
    auto mapName = Text::StripFormatCodes(app.RootMap.MapName);
    if (currentMap != mapName) {
        updateRoundNumber(0);
        trackedPlayers.DeleteAll();
        currentMapMultilap = Knowledge::UNSURE;
        currentMap = mapName;
    }

    // Fetch player data
    auto mlf = MLFeed::GetRaceData_V4();
    for (uint i = 0; i < mlf.SortedPlayers_Race.Length; i++) {
        auto player = cast<MLFeed::PlayerCpInfo_V4>(mlf.SortedPlayers_Race[i]);
        bool alreadyTracked = trackedPlayers.Exists(player.WebServicesUserId);

        // With multilap finishes we get the amazing state of having finished before even starting
        if (currentMapMultilap == Knowledge::UNSURE) {
            if (player.CpCount == 0 && player.IsFinished && player.IsSpawned) {
                currentMapMultilap = Knowledge::YEP;
            } else if (player.IsFinished && player.LastCpTime != 0) {
                currentMapMultilap = Knowledge::NOPE;
            }
        }
        bool isActuallyFinished = (currentMapMultilap != Knowledge::YEP && player.IsFinished) || uint(player.CpCount) > mlf.CpCount;

        // New finish for the player, we store it
        if (isActuallyFinished && !alreadyTracked && player.LastCpTime != 0) {
            print("Recording time for " + player.Name);
            if (recordEveryCheckpoint) {
                for (uint j = 1; j < player.CpTimes.Length - 1; j++) {
                    dumper.addEntry(mapName, player.WebServicesUserId, player.Name, player.CpTimes[j], roundNumber, 0, j, roundId);
                }
            }
            dumper.addEntry(mapName, player.WebServicesUserId, player.Name, player.LastCpTime, roundNumber, player.RoundPoints, -1, roundId);
            trackedPlayers.Set(player.WebServicesUserId, 1);
            recentlyRecordedTime = true;
            continue;
        }

        // Player was tracked, but has not finished, meaning they started a new round, so we "untrack" them
        if (!isActuallyFinished && alreadyTracked) {
            trackedPlayers.Delete(player.WebServicesUserId);
        }
    }

    // Euristically guess round switching
    if (recentlyRecordedTime && trackedPlayers.IsEmpty()) {
        updateRoundNumber(roundNumber + 1);
        recentlyRecordedTime = false;
    }
}


void Main() {
    DepCheck();
    while (true) {
        if (isRecordingTimes) {
            recordMatchTimes();
        }
        sleep(dataPollingRateMs);
    }
}
