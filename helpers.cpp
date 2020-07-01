#include <tchar.h>
#include <tlhelp32.h>
#include <psapi.h>

namespace fs = std::filesystem;
using namespace std;

#pragma comment(lib, "advapi32.lib")

namespace helpers
{

    string replaceAll(string str, const string &from, const string &to)
    {
        size_t start_pos = 0;
        while ((start_pos = str.find(from, start_pos)) != string::npos)
        {
            str.replace(start_pos, from.length(), to);
            start_pos += to.length();
        }
        return str;
    };

    vector<string> split(const string& str, const string& delim)
    {
        vector<string> tokens;
        size_t prev = 0, pos = 0;
        do
        {
            pos = str.find(delim, prev);
            if (pos == string::npos) pos = str.length();
            string token = str.substr(prev, pos-prev);
            if (!token.empty()) tokens.push_back(token);
            prev = pos + delim.length();
        }
        while (pos < str.length() && prev < str.length());
        return tokens;
    }

    DWORD get_parent_pid()
    {
        HANDLE hSnapshot;
        PROCESSENTRY32 pe32;
        DWORD ppid = 0, pid = GetCurrentProcessId();

        hSnapshot = CreateToolhelp32Snapshot(0x00000002, 0);
        __try
        {
            if (hSnapshot == INVALID_HANDLE_VALUE)
                __leave;

            ZeroMemory(&pe32, sizeof(pe32));
            pe32.dwSize = sizeof(pe32);
            if (!Process32First(hSnapshot, &pe32))
                __leave;

            do
            {
                if (pe32.th32ProcessID == pid)
                {
                    ppid = pe32.th32ParentProcessID;
                    break;
                }
            } while (Process32Next(hSnapshot, &pe32));
        }
        __finally
        {
            if (hSnapshot != INVALID_HANDLE_VALUE)
                CloseHandle(hSnapshot);
        }
        return ppid;
    }

    std::string get_filepath_by_pid(DWORD pid)
    {
        HANDLE processHandle = NULL;
        char filename[MAX_PATH];

        processHandle = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pid);
        if (processHandle != NULL)
        {
            if (GetModuleFileNameExA(processHandle, NULL, filename, MAX_PATH) == 0)
            {
                std::cout << "FEHLER";
            }
            else
            {
                std::cout << "Module filename is: " << filename << endl;
            }
            CloseHandle(processHandle);
        }
        else
        {
            std::cout << "FEHLER2";
        }
        std::string s(filename);
        return s;
    } 
    

} // namespace helpers