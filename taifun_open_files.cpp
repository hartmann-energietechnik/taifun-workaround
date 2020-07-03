// ---------------------------------------------
//  -
//  - Workaround für TAIFUN openDocuments
//  - by tsmr.eu
//  -
// ---------------------------------------------

#include <sstream>
#include <fstream>
#include <string>
#include <vector>
#include <stdio.h>
#include <iostream>
#include <windows.h>

#include <filesystem>
#include <shellapi.h>

#include "./helpers.cpp"

namespace fs = std::filesystem;
using namespace std;

#pragma comment(lib, "Shell32.lib") 
#pragma comment(lib, "User32.lib") 


bool isDev = false;
bool openAsTemp = false;
bool fileHasInfos = false; 
std::string openFileExt = "";

std::string fallback = "C:\\Windows\\system32\\notepad.exe";
std::string baseFolder = "TaifunFiles";
std::string overview_stop = "";


class AddFile {
    public:
        string ext;
        string firstChars;
        string inLineOne;
        string infotitle;
        string getinfo;
};
vector<AddFile> kownfiles;

AddFile foundKnownFile;


int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{

    // ----------------------
    // Variablen

    LPWSTR *szArglist;
    int nArgs;
    char DefChar = ' ';

    szArglist = CommandLineToArgvW(GetCommandLineW(), &nArgs);
    if( NULL == szArglist ) return 0;
    if (nArgs != 2) return 0;


    // Anwendungsverzeichnis
    char ch_dirname[MAX_PATH];
    WideCharToMultiByte(CP_ACP, 0, szArglist[0], -1, ch_dirname, MAX_PATH, &DefChar, NULL);
    std::string dirname(ch_dirname);
    dirname = fs::path(dirname).parent_path().u8string();

    // Zu öffnende Datei
    char ch_openFilePath[MAX_PATH];
    WideCharToMultiByte(CP_ACP, 0, szArglist[1], -1, ch_openFilePath, MAX_PATH, &DefChar, NULL);

    std::string openFilePath(ch_openFilePath);

    // ----------------------
    // Ausgabe

    AllocConsole();
    freopen("CONOUT$", "w", stdout);
    ShowWindow(GetConsoleWindow(), SW_HIDE);
    
    // ----------------------
    // Laden der Konfiguration

    std::string optionPath = dirname + "\\options.ini";

    if (fs::exists(optionPath)) {
        std::string line;
        std::ifstream file(optionPath);
        if (file.is_open()) {
            std::string line;

            int addfileid = 0;

            AddFile addfile;  

            while (std::getline(file, line)) {
                if (line.rfind("fallback=", 0) == 0) fallback = line.substr(9);
                if (line.rfind("isDev=", 0) == 0) isDev = line.substr(6) == "true";
                if (line.rfind("overview_stop=", 0) == 0) overview_stop = line.substr(14);

                if (line.rfind("addfile_", 0) == 0) {
                    line = line.substr(8);

                    if (line.rfind("ext=", 0) == 0) {
                        if (addfileid > 0) {
                            AddFile tmp; 

                            // TODO: besser umsetzen
                            tmp.ext = addfile.ext;
                            tmp.firstChars = addfile.firstChars;
                            tmp.inLineOne = addfile.inLineOne;
                            tmp.infotitle = addfile.infotitle;
                            tmp.getinfo = addfile.getinfo;

                            kownfiles.push_back(addfile);
                        }
                        addfileid++;

                        AddFile tmp2; 
                        addfile = tmp2;

                        addfile.ext = line.substr(4);

                        cout << "Optionen fuer " << addfile.ext << " werden geladen\n";
                        cout << addfileid << "\n";

                    }
                    if (line.rfind("firstChars=", 0) == 0) 
                        addfile.firstChars = line.substr(11);
                    if (line.rfind("inLineOne=", 0) == 0) 
                        addfile.inLineOne = line.substr(10);
                    if (line.rfind("getinfo=", 0) == 0) 
                        addfile.getinfo = line.substr(8);
                    if (line.rfind("infotitle=", 0) == 0) 
                        addfile.infotitle = line.substr(10);

                }

            }

            kownfiles.push_back(addfile);

            file.close();
        }

    }

    if (isDev) {
        ShowWindow(GetConsoleWindow(), SW_SHOW);
    }


    // ----------------------
    // Überprüfen ob die Datei von TAIFUN gestartet wurde

    std::string parentProcessPath = helpers::get_filepath_by_pid(helpers::get_parent_pid());    

    if (!isDev && parentProcessPath.find("TFW.exe") == string::npos) {
        cout << "Die Datei wurde nicht durch TAIFUN geoeffnet\n";
        ShellExecuteA(NULL, "open", fallback.c_str(), openFilePath.c_str(), NULL, SW_SHOW);
        if (isDev) system("pause");
        return 0;
    }

    

    cout << openFilePath << " wird geoeffnet...\n";


    // ----------------------
    // Datei-Kopie im Temp-Ordner erstellen


    std::string tempFolder((char *) getenv("Temp"));
    std::string baseFolder = tempFolder + "\\TaifunFiles";
    std::string fileName = fs::path(openFilePath).filename().u8string();
    std::string tempOpenFilePath = baseFolder + "\\" + fileName;

    for (AddFile &kownfile : kownfiles)
    {

        cout << "Datei wird auf " << kownfile.ext << " untersucht\n";
        cout << "kownfile.getinfo: " << kownfile.getinfo << "\n";

        ifstream infile(openFilePath);

        if (infile.good())
        {
            string sLine;
            getline(infile, sLine);

            if ( sLine.rfind(kownfile.firstChars, 0) == 0 ) {
                size_t found = sLine.find(kownfile.inLineOne); 
                if (found != string::npos) {
                    foundKnownFile = kownfile;
                    break;
                }
            }

            if (kownfile.infotitle != "" && sLine.rfind(kownfile.infotitle, 0) == 0) {
                foundKnownFile = kownfile;
                fileHasInfos = true;
                break;
            }

        }

        infile.close();

    }

    if (foundKnownFile.ext != "") {

        cout << "Es wurde der Dateityp "<< foundKnownFile.ext << " erkannt\n";
        cout << "Infos: "<< fileHasInfos << "\n";

        tempOpenFilePath += foundKnownFile.ext;

        if (fileHasInfos) {
            system(("powershell -ExecutionPolicy Bypass -F \""+dirname+"\\ps\\removeinfo.ps1\" -File \"" + openFilePath + "\" -toLineContent \"" + overview_stop + "\"").c_str());
        }

    } else {
        cout << "Dateityp nicht erkannt\n";
    }


    fs::create_directories(baseFolder);

    try {

        if (fs::exists(tempOpenFilePath)) {
            unlink(tempOpenFilePath.c_str());
        }

        fs::copy_file(openFilePath, tempOpenFilePath);

        cout << "Es wurde eine Kopie angelegt in " << tempOpenFilePath << "\n";

    } catch(fs::filesystem_error& e) {
        std::cout << e.what() << '\n';
        return 1;
    }

    // ----------------------
    // Datei als Child-Prozess öffnen und warten

    SHELLEXECUTEINFOA ShExecInfo = {0};
    ShExecInfo.cbSize = sizeof(SHELLEXECUTEINFO);
    ShExecInfo.fMask = SEE_MASK_NOCLOSEPROCESS;
    ShExecInfo.hwnd = NULL;
    ShExecInfo.lpVerb = NULL;

    if (foundKnownFile.ext != "") {
        ShExecInfo.lpFile = tempOpenFilePath.c_str();    
        ShExecInfo.lpParameters = "";
    } else {
        cout << "Zum oeffnen der Datei wird der Fallback \"" << fallback << "\" verwenden.\n";
        ShExecInfo.lpFile = fallback.c_str();    
        ShExecInfo.lpParameters = tempOpenFilePath.c_str();
    }

    ShExecInfo.lpDirectory = NULL;
    ShExecInfo.nShow = SW_SHOW;

    cout << "Kopie wird geoeffnet\n";

    ShExecInfo.hInstApp = NULL; 
    ShellExecuteExA(&ShExecInfo);
    WaitForSingleObject(ShExecInfo.hProcess, INFINITE);
    CloseHandle(ShExecInfo.hProcess);


    // ----------------------
    // Übersicht in die Datei einfügen

    if (foundKnownFile.ext != "" && foundKnownFile.getinfo != "") {

        cout << "Es wird eine Zusammenfassung der Datei mit " << foundKnownFile.getinfo << " erstellt. \n";

        system(("powershell -ExecutionPolicy Bypass -F \""+dirname+"\\ps\\"+foundKnownFile.getinfo+"\" -sourceFile \"" + tempOpenFilePath + "\" -saveFile \""+dirname+"\\overview.txt\"").c_str());
        
        std::ofstream outfile;

        outfile.open(dirname + "\\overview.txt", std::ios_base::app);
        outfile << overview_stop << "\n";
        outfile.close();

        system(("powershell -ExecutionPolicy Bypass -F \""+dirname+"\\ps\\addinfo.ps1\" -File \"" + tempOpenFilePath + "\" -FileAdd \""+dirname+"\\overview.txt\"").c_str());

        unlink((dirname + "\\overview.txt").c_str());
    
    }

    // ----------------------
    // Änderungen zurückkopieren

    try {

        cout << "Aenderungen werden zurueckkopiert\n";

        if (fs::exists(openFilePath)) {
            unlink(openFilePath.c_str());
        }

        fs::copy_file(tempOpenFilePath, openFilePath);

        unlink(tempOpenFilePath.c_str());


    } catch(fs::filesystem_error& e) {
        std::cout << e.what() << '\n';
        return 1;
    }

    if (isDev) {
        system("pause");
    }

    return 0;

}