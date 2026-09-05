; ============================================================
; Customizing 레포 인덱서
; 레포 루트에 이 스크립트를 두고 실행하면 하위 폴더의 index.html을
; 전부 찾아 pages.json으로 저장한다.
; 이후 자동 커밋 도구가 pages.json 변경분을 커밋/배포한다.
; ============================================================
#NoEnv
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1

RootDir := A_ScriptDir
OutputFile := RootDir . "\pages.json"

delimList := ""
count := 0

Loop, Files, %RootDir%\*.html, R
{
    if (A_LoopFileName != "index.html")
        continue

    ; 루트 자신의 index.html은 제외
    if (A_LoopFileDir = RootDir)
        continue

    ; RootDir 기준 상대 경로로 변환, 역슬래시 -> 슬래시
    relDir := SubStr(A_LoopFileDir, StrLen(RootDir) + 2)
    relDir := StrReplace(relDir, "\", "/")

    delimList .= relDir . "`n"
    count++
}

if (count = 0)
{
    MsgBox, 하위 폴더에서 index.html을 찾지 못했습니다.
    ExitApp
}

; 사전순 정렬
delimList := RTrim(delimList, "`n")
Sort, delimList
paths := StrSplit(delimList, "`n")

; JSON 배열 문자열 생성
json := "["
for index, path in paths
{
    if (index > 1)
        json .= ","
    json .= "`n  """ . JsonEscape(path) . """"
}
json .= "`n]`n"

if FileExist(OutputFile)
    FileDelete, %OutputFile%
FileAppend, %json%, %OutputFile%, UTF-8-RAW

TrayTip, 인덱서 완료, % count . "개의 index.html을 찾아 pages.json에 저장했습니다.", 3
ExitApp

JsonEscape(str) {
    str := StrReplace(str, "\", "\\")
    str := StrReplace(str, """", "\""")
    return str
}
