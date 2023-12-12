/**
 * Class implementing interface to store records in CSV file
 */

const string csvHeaders = "Time,Track,PlayerID,PlayerName,Record,RoundNumber";

class MatchDump {

    string filepath;
    private IO::File handle;
    private bool closed;
    private bool recordPoints;

    MatchDump(const string&in basename, const bool recordPoints=false) {
        this.filepath = IO::FromStorageFolder(basename) + ".csv";
        if (IO::FileExists(filepath)) {
            this.handle.Open(this.filepath, IO::FileMode::Append);
        } else {
            this.handle.Open(this.filepath, IO::FileMode::Write);
            this.handle.Write(csvHeaders + (recordPoints ? ",Points" : "") + "\n");
        }
        this.recordPoints = recordPoints;
        this.closed = false;
    }

    void addEntry(
        const string&in track,
        const string&in playerID,
        const string&in playerName,
        const int record,
        const int round=0,
        const int points=-1
    ) {
        array<string> lineData = {
            Text::Format("%d", Time::get_Stamp()),
            track,
            playerID,
            playerName,
            Text::Format("%d", record),
            Text::Format("%d", round),
            Text::Format("%d", points)
        };
        if (!this.recordPoints) lineData.RemoveLast();
        this.handle.Write(string::Join(lineData, ",") + "\n");
        this.handle.Flush();
    }

    void close() {
        this.handle.Close();
        this.closed = true;
    }

    bool isClosed() {
        return this.closed;
    }

}
