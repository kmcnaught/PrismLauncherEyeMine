// EyeMine launcher wrapper.
// Windows GUI subsystem executable (no console window) that launches
// launcher\prismlauncher.exe --launch EyeMineV2 relative to its own location.
//
// Intentionally uses only Win32 API (no C++ standard library) so that the
// executable has no dependency on libc++.dll or any other runtime DLL.

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

// Maximum extended-length path (\\?\ prefix allows up to 32767 chars)
static const DWORD PATH_BUF = 32768;

int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
    wchar_t selfPath[PATH_BUF];
    DWORD len = GetModuleFileNameW(nullptr, selfPath, PATH_BUF);
    if (len == 0 || len >= PATH_BUF) {
        MessageBoxW(nullptr, L"Failed to determine LaunchMinecraftForEyeMine.exe location.", L"EyeMine", MB_OK | MB_ICONERROR);
        return 1;
    }

    // Truncate at the last backslash to get the containing directory.
    wchar_t* lastSlash = nullptr;
    for (wchar_t* p = selfPath; *p; ++p) {
        if (*p == L'\\')
            lastSlash = p;
    }
    if (lastSlash)
        *lastSlash = L'\0';

    // Build launcher path and working directory (both inside launcher\).
    wchar_t launcher[PATH_BUF];
    wchar_t workDir[PATH_BUF];
    lstrcpyW(launcher, selfPath);
    lstrcatW(launcher, L"\\launcher\\prismlauncher.exe");
    lstrcpyW(workDir, selfPath);
    lstrcatW(workDir, L"\\launcher");

    // mutable buffer required by CreateProcessW
    wchar_t cmdLine[PATH_BUF];
    lstrcpyW(cmdLine, L"\"");
    lstrcatW(cmdLine, launcher);
    lstrcatW(cmdLine, L"\" --launch EyeMineV2");

    STARTUPINFOW si;
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    PROCESS_INFORMATION pi;
    ZeroMemory(&pi, sizeof(pi));

    if (!CreateProcessW(launcher, cmdLine, nullptr, nullptr, FALSE, 0,
                        nullptr, workDir, &si, &pi)) {
        DWORD err = GetLastError();
        wchar_t errStr[32];
        // wsprintfW is a Win32 function — no C runtime needed.
        wsprintfW(errStr, L"%lu", err);
        wchar_t msg[PATH_BUF];
        lstrcpyW(msg, L"Failed to launch:\n");
        lstrcatW(msg, launcher);
        lstrcatW(msg, L"\n\nError code: ");
        lstrcatW(msg, errStr);
        MessageBoxW(nullptr, msg, L"EyeMine", MB_OK | MB_ICONERROR);
        return 1;
    }

    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);

    return 0;
}
