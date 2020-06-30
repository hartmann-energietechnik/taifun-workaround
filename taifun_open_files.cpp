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
std::string openFileExt = "";

std::string fallback = "C:\\Windows\\system32\\notepad.exe";
std::string baseFolder = "TaifunFiles";
std::string allowedfiles = "";


int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{

    int argc = 0;
    char** argv;
    helpers::fetchCmdArgs(&argc, &argv);

    if (argc != 2) return 0;

    std::string dirname = helpers::replaceAll(argv[0], "\"", "");
    dirname = fs::path(dirname).parent_path().u8string();

    std::string openFilePath = helpers::replaceAll(argv[1], "\"", "");


    // ----------------------
    // Überprüfen ob die Datei von TAIFUN gestartet wurde

    std::string parentProcessPath = helpers::get_filepath_by_pid(helpers::get_parent_pid());    

    std::cout << parentProcessPath << "\\n";

    if (parentProcessPath.find("TFW.exe") == string::npos) {
        ShellExecuteA(NULL, "open", fallback.c_str(), argv[1], NULL, SW_SHOW);
        return 0;
    }

    cout << openFilePath << " wird geoeffnet...\n";


    // ----------------------
    // Laden der Konfiguration

    std::string optionPath = dirname + "\\options.ini";
    cout << "Konfiguartion wird geladen aus: " << optionPath << "\n";

    if (fs::exists(optionPath)) {
        std::string line;
        std::ifstream file(optionPath);
        if (file.is_open()) {
            std::string line;
            while (std::getline(file, line)) {
                if (line.rfind("fallback=", 0) == 0) fallback = line.substr(9);
                if (line.rfind("allowedfiles=", 0) == 0) allowedfiles = line.substr(13);
                if (line.rfind("isDev=", 0) == 0) isDev = line.substr(6) == "true";
            }
            file.close();
        }

    }

    if (isDev) {
        AllocConsole();
        freopen("CONOUT$", "w", stdout);
    }

    cout << "allowedfiles=" << allowedfiles << "\n";

    vector<string> allowedfiles_array = helpers::split(allowedfiles, ",");


    // ----------------------
    // Datei-Kopie im Temp-Ordner erstellen

    std::string tempFolder((char *) getenv("Temp"));
    std::string baseFolder = tempFolder + "\\TaifunFiles";
    std::string fileName = fs::path(openFilePath).filename().u8string();
    std::string tempOpenFilePath = baseFolder + "\\" + fileName;

    for (auto &allowedfile : allowedfiles_array)
    {
        vector<string> file_data = helpers::split(allowedfile, ":");

        ifstream infile(openFilePath);

        if (infile.good())
        {
            string sLine;
            getline(infile, sLine);

            if (sLine.rfind(file_data[0], 0) == 0) {
                tempOpenFilePath += file_data[1];
                openAsTemp = true;
                cout << "Erkannt als " << file_data[1] << "\n";
            }

        }

        infile.close();

    }

    if (!openAsTemp) {
        cout << "Datei nicht erkannt\n";
    }

    fs::create_directories(baseFolder);

    try {

        if (fs::exists(tempOpenFilePath)) {
            unlink(tempOpenFilePath.c_str());
        }
        fs::copy_file(openFilePath, tempOpenFilePath);

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

    if (openAsTemp) {
        ShExecInfo.lpFile = tempOpenFilePath.c_str();    
        ShExecInfo.lpParameters = "";
    } else {
        ShExecInfo.lpFile = fallback.c_str();    
        ShExecInfo.lpParameters = tempOpenFilePath.c_str();
    }

    ShExecInfo.lpDirectory = NULL;
    ShExecInfo.nShow = SW_SHOW;
    ShExecInfo.hInstApp = NULL; 
    ShellExecuteExA(&ShExecInfo);
    WaitForSingleObject(ShExecInfo.hProcess, INFINITE);
    CloseHandle(ShExecInfo.hProcess);


    // ----------------------
    // Änderungen zurückkopieren

    try {

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