/**
 * Class implementing interface to store records in CSV file
 */

const string csvHeaders = "Time,Track,PlayerID,PlayerName,Record,RoundNumber";

class MatchDump {

    string filepath;
    private IO::File handle;
    private bool closed;
    private bool recordPoints;
    private bool recordCPs;
    private bool recordRoundId;

    MatchDump(
        const string&in basename,
        const bool recordPoints=false,
        const bool recordCPs=false,
        const bool recordRoundId=false
    ) {
        this.filepath = IO::FromStorageFolder(basename) + ".csv";
        if (IO::FileExists(filepath)) {
            this.handle.Open(this.filepath, IO::FileMode::Append);
        } else {
            this.handle.Open(this.filepath, IO::FileMode::Write);
            this.handle.Write(
                csvHeaders
                + (recordPoints ? ",Points" : "")
                + (recordCPs ? ",CP" : "")
                + (recordRoundId ? ",RoundID" : "")
                + "\n"
            );
        }
        this.recordPoints = recordPoints;
        this.recordCPs = recordCPs;
        this.recordRoundId = recordRoundId;
        this.closed = false;
    }

    void addEntry(
        const string&in track,
        const string&in playerID,
        const string&in playerName,
        const int record,
        const int round=0,
        const int points=-1,
        const int checkpoint=-1,
        const string&in _roundId=""
    ) {
        array<string> lineData = {
            Text::Format("%d", Time::get_Stamp()),
            track,
            playerID,
            playerName,
            Text::Format("%d", record),
            Text::Format("%d", round)
        };
        if (this.recordPoints) {
            lineData.InsertLast(Text::Format("%d", points));
        }
        if (this.recordCPs) {
            lineData.InsertLast(checkpoint < 0 ? "finish": Text::Format("%d", checkpoint));
        }
        if (this.recordRoundId) {
            lineData.InsertLast(_roundId);
        }
        this.handle.Write(string::Join(lineData, ",") + "\n");
        if (!this.recordPoints || checkpoint < 0) this.handle.Flush();
    }

    void close() {
        this.handle.Close();
        this.closed = true;
    }

    bool isClosed() {
        return this.closed;
    }

}
