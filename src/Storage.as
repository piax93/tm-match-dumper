class MatchDump {

    private const string csvHeaders = "Time,Track,PlayerID,PlayerName,Record";

    string filepath;
    private IO::File handle;

    MatchDump(const string&in basename) {
        this.filepath = IO::FromStorageFolder(basename) + ".csv";
        if (IO::FileExists(filepath)) {
            this.handle = IO::File(this.filepath, IO::FileMode::Append);
        } else {
            this.handle = IO::File(this.filepath, IO::FileMode::Write);
            this.handle.Write(csvHeaders + "\n");
        }
    }

    void addEntry(const string& playerID, const string&in playerName, const int record) {
        array<string> lineData(
            Text::Format("%d", Time::get_Stamp()),
            this.getCurrentTrack(),
            playerID,
            playerName,
            Text::Format("%d", record),
        );
        this.handle.Write(string::Join(lineData, ",") + "\n");
    }

    string getCurrentTrack() {
        return "";
    }

}
