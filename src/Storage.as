/**
 * Class implementing interface to store records in CSV file
 */

const string csvHeaders = "Time,Track,PlayerID,PlayerName,Record";

class MatchDump {

    string filepath;
    private IO::File handle;
    private bool closed;

    MatchDump(const string&in basename) {
        this.filepath = IO::FromStorageFolder(basename) + ".csv";
        if (IO::FileExists(filepath)) {
            this.handle.Open(this.filepath, IO::FileMode::Append);
        } else {
            this.handle.Open(this.filepath, IO::FileMode::Write);
            this.handle.Write(csvHeaders + "\n");
        }
        this.closed = false;
    }

    void addEntry(
        const string&in track,
        const string&in playerID,
        const string&in playerName,
        const int record
    ) {
        array<string> lineData = {
            Text::Format("%d", Time::get_Stamp()),
            track,
            playerID,
            playerName,
            Text::Format("%d", record),
        };
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
