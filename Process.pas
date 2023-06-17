{
This file is part of the Free Component Library (FCL)
Copyright (c) 1999-2000 by the Free Pascal development team

See the file COPYING.FPC, included in this distribution,
for details about the copyright.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit Process;

interface

uses
  System.Classes, System.Types, System.SysUtils, Pipes;

type
  TProcessOption = (poRunSuspended, poWaitOnExit, poUsePipes, poStderrToOutPut, poNoConsole, poNewConsole, poDefaultErrorMode, poNewProcessGroup, poDebugProcess, poDebugOnlyThisProcess);

  TShowWindowOptions = (swoNone, swoHIDE, swoMaximize, swoMinimize, swoRestore, swoShow, swoShowDefault, swoShowMaximized, swoShowMinimized, swoshowMinNOActive, swoShowNA, swoShowNoActivate, swoShowNormal);

  TStartupOption = (suoUseShowWindow, suoUseSize, suoUsePosition, suoUseCountChars, suoUseFillAttribute);

  TProcessPriority = (ppHigh, ppIdle, ppNormal, ppRealTime);

  TProcessOptions = set of TProcessOption;

  TStartupOptions = set of TStartupOption;

type
  {$IFDEF MACOS}
  TProcessForkEvent = procedure(Sender: TObject) of object;
  {$ENDIF}

  { TProcess }

  TProcess = class(TComponent)
  private
    FProcessOptions: TProcessOptions;
    FStartupOptions: TStartupOptions;
    FProcessID: Integer;
    FThreadID: Integer;
    FProcessHandle: Thandle;
    FThreadHandle: Thandle;
    FFillAttribute: Cardinal;
    FApplicationName: string;
    FConsoleTitle: string;
    FCommandLine: string;
    FCurrentDirectory: string;
    FDesktop: string;
    FEnvironment: Tstrings;
    FExecutable: string;
    FParameters: TStrings;
    FShowWindow: TShowWindowOptions;
    FInherithandles: Boolean;
    {$IFDEF MACOS}
    FForkEvent: TProcessForkEvent;
    {$ENDIF}
    FProcessPriority: TProcessPriority;
    dwXCountchars, dwXSize, dwYsize, dwx, dwYcountChars, dwy: Cardinal;
    FXTermProgram: string;
    FPipeBufferSize: Cardinal;
    procedure FreeStreams;
    function GetExitStatus: Integer;
    function GetExitCode: Integer;
    function GetRunning: Boolean;
    function GetWindowRect: TRect;
    procedure SetCommandLine(const AValue: string);
    procedure SetParameters(const AValue: TStrings);
    procedure SetWindowRect(Value: TRect);
    procedure SetShowWindow(Value: TShowWindowOptions);
    procedure SetWindowColumns(Value: Cardinal);
    procedure SetWindowHeight(Value: Cardinal);
    procedure SetWindowLeft(Value: Cardinal);
    procedure SetWindowRows(Value: Cardinal);
    procedure SetWindowTop(Value: Cardinal);
    procedure SetWindowWidth(Value: Cardinal);
    procedure SetApplicationName(const Value: string);
    procedure SetProcessOptions(const Value: TProcessOptions);
    procedure SetActive(const Value: Boolean);
    procedure SetEnvironment(const Value: TStrings);
    procedure ConvertCommandLine;
    function PeekExitStatus: Boolean;
  protected
    FRunning: Boolean;
    FExitCode: Cardinal;
    FInputStream: TOutputPipeStream;
    FOutputStream: TInputPipeStream;
    FStdErrorStream: TInputPipeStream;
    procedure CloseProcessHandles; virtual;
    procedure CreateStreams(InHandle, OutHandle, ErrHandle: Longint); virtual;
    procedure FreeStream(var AStream: THandleStream);
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Execute; virtual;
    procedure CloseInput; virtual;
    procedure CloseOutput; virtual;
    procedure CloseStderr; virtual;
    function Resume: Integer; virtual;
    function Suspend: Integer; virtual;
    function Terminate(AExitCode: Integer): Boolean; virtual;
    function WaitOnExit: Boolean;
    property WindowRect: Trect read GetWindowRect write SetWindowRect;
    property Handle: THandle read FProcessHandle;
    property ProcessHandle: THandle read FProcessHandle;
    property ThreadHandle: THandle read FThreadHandle;
    property ProcessID: Integer read FProcessID;
    property ThreadID: Integer read FThreadID;
    property Input: TOutputPipeStream read FInputStream;
    property Output: TInputPipeStream read FOutputStream;
    property StdError: TinputPipeStream read FStdErrorStream;
    property ExitStatus: Integer read GetExitStatus;
    property ExitCode: Integer read GetExitCode;
    property InheritHandles: Boolean read FInheritHandles write FInheritHandles;
    {$IFDEF MACOS}
    property OnForkEvent: TProcessForkEvent read FForkEvent write FForkEvent;
    {$ENDIF}
  published
    property PipeBufferSize: cardinal read FPipeBufferSize write FPipeBufferSize default 1024;
    property Active: Boolean read GetRunning write SetActive;
    property ApplicationName: string read FApplicationName write SetApplicationName;
    property CommandLine: string read FCommandLine write SetCommandLine;
    property Executable: string read FExecutable write FExecutable;
    property Parameters: TStrings read FParameters write SetParameters;
    property ConsoleTitle: string read FConsoleTitle write FConsoleTitle;
    property CurrentDirectory: string read FCurrentDirectory write FCurrentDirectory;
    property Desktop: string read FDesktop write FDesktop;
    property Environment: TStrings read FEnvironment write SetEnvironment;
    property Options: TProcessOptions read FProcessOptions write SetProcessOptions;
    property Priority: TProcessPriority read FProcessPriority write FProcessPriority;
    property StartupOptions: TStartupOptions read FStartupOptions write FStartupOptions;
    property Running: Boolean read GetRunning;
    property ShowWindow: TShowWindowOptions read FShowWindow write SetShowWindow;
    property WindowColumns: Cardinal read dwXCountChars write SetWindowColumns;
    property WindowHeight: Cardinal read dwYSize write SetWindowHeight;
    property WindowLeft: Cardinal read dwX write SetWindowLeft;
    property WindowRows: Cardinal read dwYCountChars write SetWindowRows;
    property WindowTop: Cardinal read dwY write SetWindowTop;
    property WindowWidth: Cardinal read dwXSize write SetWindowWidth;
    property FillAttribute: Cardinal read FFillAttribute write FFillAttribute;
    property XTermProgram: string read FXTermProgram write FXTermProgram;
  end;

  EProcess = class(Exception);

procedure CommandToList(S: string; List: TStrings);

{$IFDEF MACOS}
var
  TryTerminals: array of string;
  XTermProgram: string;

function DetectXTerm: string;
{$ENDIF}

function RunCommandIndir(const CurDir: string; const ExeName: string; const Commands: array of string; out OutputString: AnsiString; out ExitStatus: Integer; Options: TProcessOptions = []): integer; overload;

function RunCommandIndir(const CurDir: string; const ExeName: string; const Commands: array of string; out OutputString: AnsiString; Options: TProcessOptions = []): Boolean; overload;

function RunCommand(const ExeName: string; const Commands: array of string; out OutputString: AnsiString; Options: TProcessOptions = []): Boolean; overload;

function RunCommandInDir(const CurDir, CmdLine: string; out OutputString: AnsiString): Boolean; deprecated; overload;

function RunCommand(const CmdLine: string; out OutputString: AnsiString): Boolean; deprecated; overload;

implementation

{$IFDEF MACOS}
  //need implement
{$ENDIF}

{$IFDEF MSWINDOWS}

uses
  Winapi.Windows;

resourcestring
  SNoCommandLine = 'Cannot execute empty command-line';
  SErrCannotExecute = 'Failed to execute %s : %d';
//SErrNoSuchProgram     = 'Executable not found: "%s"';
//SErrNoTerminalProgram = 'Could not detect X-Terminal program';}

const
  PriorityConstants: array[TProcessPriority] of Cardinal =
    (HIGH_PRIORITY_CLASS, IDLE_PRIORITY_CLASS,
    NORMAL_PRIORITY_CLASS, REALTIME_PRIORITY_CLASS);
{$ENDIF}

procedure CommandToList(S: string; List: TStrings);

  function GetNextWord: string;
  const
    WhiteSpace =[' ', #9, #10, #13];
    Literals =['"', ''''];
  var
    WStart, WEnd: Integer;
    InLiteral: Boolean;
    LastLiteral: char;
  begin
    WStart := 1;
    while (WStart <= Length(S)) and (CharInSet(S[WStart], WhiteSpace)) do
      Inc(WStart);
    WEnd := WStart;
    InLiteral := False;
    LastLiteral := #0;
    while (WEnd <= Length(S)) and (not (CharInSet(S[WEnd], WhiteSpace)) or InLiteral) do
    begin
      if CharInSet(S[WEnd], Literals) then
        if InLiteral then
          InLiteral := not (S[WEnd] = LastLiteral)
        else
        begin
          InLiteral := True;
          LastLiteral := S[WEnd];
        end;
      Inc(WEnd);
    end;

    Result := Copy(S, WStart, WEnd - WStart);
    if (Length(Result) > 0)
      and (Result[1] = Result[Length(Result)]) // if 1st char = last char and..
        and (CharInSet(Result[1], Literals)) then // it's one of the literals, then
      Result := Copy(Result, 2, Length(Result) - 2); //delete the 2 (but not others in it)
    while (WEnd <= Length(S)) and (CharInSet(S[WEnd], WhiteSpace)) do
      Inc(WEnd);
    Delete(S, 1, WEnd - 1);
  end;

var
  W: string;
begin
  while Length(S) > 0 do
  begin
    W := GetNextWord;
    if W <> '' then
      List.Add(W);
  end;
end;

{$IFDEF MSWINDOWS}
function GetStartupFlags(Process: TProcess): Cardinal;
begin
  with Process do
  begin
    Result := 0;
    if poUsePipes in FProcessOptions then
      Result := Result or STARTF_USESTDHANDLES;
    if suoUseShowWindow in FStartupOptions then
      Result := Result or STARTF_USESHOWWINDOW;
    if suoUSESIZE in FStartupOptions then
      Result := Result or STARTF_USESIZE;
    if suoUsePosition in FStartupOptions then
      Result := Result or STARTF_USEPOSITION;
    if suoUSECOUNTCHARS in FStartupoptions then
      Result := Result or STARTF_USECOUNTCHARS;
    if suoUsefIllAttribute in FStartupOptions then
      Result := Result or STARTF_USEFILLATTRIBUTE;
  end;
end;

function GetCreationFlags(Process: TProcess): Cardinal;
begin
  with Process do
  begin
    Result := 0;
    if poNoConsole in FProcessOptions then
      Result := Result or DETACHED_PROCESS;
    if poNewConsole in FProcessOptions then
      Result := Result or CREATE_NEW_CONSOLE;
    if poNewProcessGroup in FProcessOptions then
      Result := Result or CREATE_NEW_PROCESS_GROUP;
    if poRunSuspended in FProcessOptions then
      Result := Result or CREATE_SUSPENDED;
    if poDebugProcess in FProcessOptions then
      Result := Result or DEBUG_PROCESS;
    if poDebugOnlyThisProcess in FProcessOptions then
      Result := Result or DEBUG_ONLY_THIS_PROCESS;
    if poDefaultErrorMode in FProcessOptions then
      Result := Result or CREATE_DEFAULT_ERROR_MODE;
    Result := Result or PriorityConstants[FProcessPriority];
  end;
end;

function StringsToPChars(List: TStrings): pointer;
var
  i, MemSize: Integer;
  EnvBlock, Item: AnsiString;
begin
  EnvBlock := '';
  for i := 0 to List.Count - 1 do
  begin
    Item := AnsiString(List[i]);
    EnvBlock := EnvBlock + Item + #0;
  end;
  EnvBlock := EnvBlock + #0;
  MemSize := Length(EnvBlock);  // if using unicode in the future, remember CHAR size (4) for memory allocation
  GetMem(Result, MemSize);
  CopyMemory(Result, @EnvBlock[1], MemSize);
end;

procedure InitProcessAttributes(Process: TProcess; var Attributes: TSecurityAttributes);
begin
  FillChar(Attributes, SizeOf(Attributes), 0);
  Attributes.nLength := SizeOf(Attributes);
end;

procedure InitThreadAttributes(Process: TProcess; var Attributes: TSecurityAttributes);
begin
  FillChar(Attributes, SizeOf(Attributes), 0);
  Attributes.nLength := SizeOf(Attributes);
end;

procedure InitStartupInfo(Process: TProcess; var StartupInfo: TStartupInfo);
const
  SWC: array[TShowWindowOptions] of Cardinal =
    (0, SW_HIDE, SW_MAXIMIZE, SW_MINIMIZE, SW_RESTORE, SW_SHOW,
    SW_SHOWDEFAULT, SW_SHOWMAXIMIZED, SW_SHOWMINIMIZED,
    SW_SHOWMINNOACTIVE, SW_SHOWNA, SW_SHOWNOACTIVATE, SW_SHOWNORMAL);
begin
  FillChar(StartupInfo, SizeOf(StartupInfo), 0);
  with StartupInfo do
  begin
    dwFlags := GetStartupFlags(Process);
    if Process.ShowWindow <> swoNone then
      dwFlags := dwFlags or STARTF_USESHOWWINDOW
    else
      dwFlags := dwFlags and not STARTF_USESHOWWINDOW;
    wShowWindow := SWC[Process.ShowWindow];
    if (poUsePipes in Process.Options) then
      dwFlags := dwFlags or STARTF_USESTDHANDLES;
    if Process.FillAttribute <> 0 then
    begin
      dwFlags := dwFlags or STARTF_USEFILLATTRIBUTE;
      dwFillAttribute := Process.FillAttribute;
    end;
    dwXCountChars := Process.WindowColumns;
    dwYCountChars := Process.WindowRows;
    dwYsize := Process.WindowHeight;
    dwXsize := Process.WindowWidth;
    dwy := Process.WindowTop;
    dwX := Process.WindowLeft;
  end;
end;

procedure CreatePipes(var HInput, HOutput, HError: THandle; var StartupInfo: TStartupInfo; CreateError: Boolean; APipeBufferSize: Cardinal);

  { The handles that are to be passed to the child process must be
  inheritable. On the other hand, only non-inheritable handles
  allow the sending of EOF when the write-end is closed. This
  function is used to duplicate the child process's ends of the
  handles into inheritable ones, leaving the parent-side handles
  non-inheritable.}
  function DuplicateHandleFP(var Handle: THandle): Boolean;
  var
    oldHandle: THandle;
  begin
    oldHandle := Handle;
    Result := DuplicateHandle(
      GetCurrentProcess(), oldHandle,
      GetCurrentProcess(), @Handle, 0, True,
      DUPLICATE_SAME_ACCESS);
    if Result then
      Result := CloseHandle(oldHandle);
  end;

begin
  CreatePipeHandles(StartupInfo.hStdInput, HInput, APipeBufferSize);
  DuplicateHandleFP(StartupInfo.hStdInput);
  CreatePipeHandles(HOutput, StartupInfo.hStdOutput, APipeBufferSize);
  DuplicateHandleFP(StartupInfo.hStdOutput);
  if CreateError then
  begin
    CreatePipeHandles(HError, StartupInfo.hStdError, APipeBufferSize);
    DuplicateHandleFP(StartupInfo.hStdError);
  end
  else
  begin
    StartupInfo.hStdError := StartupInfo.hStdOutput;
    HError := HOutput;
  end;
end;

function MaybeQuote(const S: string): string;
begin
  if (Pos(' ', S) <> 0) then
    Result := '"' + S + '"'
  else
    Result := S;
end;

function MaybeQuoteIfNotQuoted(const S: string): string;
begin
  if (Pos(' ', S) <> 0) and (Pos('"', S) = 0) then
    Result := '"' + S + '"'
  else
    Result := S;
end;
{$ENDIF}

procedure TProcess.CloseProcessHandles;
begin
  {$IFDEF MSWINDOWS}
  if (FProcessHandle <> 0) then
    CloseHandle(FProcessHandle);
  if (FThreadHandle <> 0) then
    CloseHandle(FThreadHandle);
  {$ENDIF}
end;

function TProcess.PeekExitStatus: Boolean;
begin
  {$IFDEF MSWINDOWS}
  GetExitCodeProcess(ProcessHandle, FExitCode);
  Result := FExitCode <> STILL_ACTIVE;
  {$ENDIF}
end;

procedure TProcess.Execute;
{$IFDEF MSWINDOWS}
var
  i: Integer;
  PName, PDir, PCommandLine: PChar;
  FEnv: Pointer;
  FCreationFlags: Cardinal;
  FProcessAttributes: TSecurityAttributes;
  FThreadAttributes: TSecurityAttributes;
  FProcessInformation: TProcessInformation;
  FStartupInfo: STARTUPINFOW;
  HI, HO, HE: THandle;
  Cmd: string;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  PName := nil;
  PCommandLine := nil;
  PDir := nil;

  if (FApplicationName = '') and (FCommandLine = '') and (FExecutable = '') then
    raise EProcess.Create(SNoCommandline);
  if (FApplicationName <> '') then
  begin
    PName := PChar(FApplicationName);
    PCommandLine := PChar(FCommandLine);
  end
  else if (FCommandLine <> '') then
    PCommandLine := PChar(FCommandLine)
  else if (Fexecutable <> '') then
  begin
    Cmd := MaybeQuoteIfNotQuoted(Executable);
    for i := 0 to Parameters.Count - 1 do
      Cmd := Cmd + ' ' + MaybeQuoteIfNotQuoted(Parameters[i]);
    PCommandLine := PChar(Cmd);
  end;
  if FCurrentDirectory <> '' then
    PDir := PChar(FCurrentDirectory);
  if FEnvironment.Count <> 0 then
    FEnv := StringsToPChars(FEnvironment)
  else
  begin
    // writeln('DEBUG: environment nil');
    FEnv := nil;
  end;

  try
    FCreationFlags := GetCreationFlags(Self);
    InitProcessAttributes(Self, FProcessAttributes);
    InitThreadAttributes(Self, FThreadAttributes);
    InitStartupInfo(Self, FStartupInfo);
    if poUsePipes in FProcessOptions then
      CreatePipes(HI, HO, HE, FStartupInfo, not (poStdErrToOutPut in FProcessOptions), FPipeBufferSize);

    try
      if not CreateProcessW(PName, PCommandLine, @FProcessAttributes, @FThreadAttributes,
        FInheritHandles, FCreationFlags, FEnv, PDir, FStartupInfo,
        FProcessInformation) then
        raise EProcess.CreateFmt(SErrCannotExecute, [FCommandLine, GetLastError]);
      FProcessHandle := FProcessInformation.hProcess;
      FThreadHandle := FProcessInformation.hThread;
      FProcessID := FProcessInformation.dwProcessID;
    finally
      if POUsePipes in FProcessOptions then
      begin
        FileClose(FStartupInfo.hStdInput);
        FileClose(FStartupInfo.hStdOutput);
        if not (poStdErrToOutPut in FProcessOptions) then
          FileClose(FStartupInfo.hStdError);
        CreateStreams(HI, HO, HE);
      end;
    end;
    FRunning := True;
  finally
    if FEnv <> nil then
      FreeMem(FEnv);
  end;
  if not (csDesigning in ComponentState) and // This would hang the IDE !
    (poWaitOnExit in FProcessOptions) and
    not (poRunSuspended in FProcessOptions) then
    WaitOnExit;
  {$ENDIF}
end;

function TProcess.WaitOnExit: Boolean;
begin
  {$IFDEF MSWINDOWS}
  Result := WaitForSingleObject(FProcessHandle, Infinite) <> WAIT_FAILED;
  if Result then
    GetExitStatus;
  FRunning := False;
  {$ENDIF}
end;

function TProcess.Suspend: Longint;
begin
  {$IFDEF MSWINDOWS}
  Result := SuspendThread(ThreadHandle);
  {$ENDIF}
end;

function TProcess.Resume: LongInt;
begin
  {$IFDEF MSWINDOWS}
  Result := ResumeThread(ThreadHandle);
  {$ENDIF}
end;

function TProcess.Terminate(AExitCode: Integer): Boolean;
begin
  {$IFDEF MSWINDOWS}
  Result := False;
  if ExitStatus = STILL_ACTIVE then
    Result := TerminateProcess(Handle, AExitCode);
  {$ENDIF}
end;

constructor TProcess.Create(AOwner: TComponent);
begin
  inherited;
  FProcessPriority := ppNormal;
  FShowWindow := swoNone;
  FInheritHandles := True;
  {$IFDEF MACOS}
  FForkEvent := nil;
  {$ENDIF}
  FPipeBufferSize := 1024;
  FEnvironment := TStringList.Create;
  FParameters := TStringList.Create;
end;

destructor TProcess.Destroy;
begin
  FParameters.Free;
  FEnvironment.Free;
  FreeStreams;
  CloseProcessHandles;
  inherited Destroy;
end;

procedure TProcess.SetShowWindow(Value: TShowWindowOptions);
begin
  FShowWindow := Value;
end;

procedure TProcess.FreeStreams;
begin
  if FStdErrorStream <> FOutputStream then
    FreeStream(THandleStream(FStdErrorStream));
  FreeStream(THandleStream(FOutputStream));
  FreeStream(THandleStream(FInputStream));
end;

function TProcess.GetExitStatus: Integer;
begin
  GetRunning;
  Result := FExitCode;
end;

{$IFNDEF OS_HASEXITCODE}
function TProcess.GetExitCode: Integer;
begin
  if not Running then
    Result := GetExitStatus
  else
    Result := 0
end;
{$ENDIF}

function TProcess.GetRunning: Boolean;
begin
  if FRunning then
    FRunning := not PeekExitStatus;
  Result := FRunning;
end;

procedure TProcess.CreateStreams(InHandle, OutHandle, ErrHandle: Longint);
begin
  FreeStreams;
  FInputStream := TOutputPipeStream.Create(InHandle);
  FOutputStream := TInputPipeStream.Create(OutHandle);
  if not (poStderrToOutput in FProcessOptions) then
    FStdErrorStream := TInputPipeStream.Create(ErrHandle);
end;

procedure TProcess.FreeStream(var AStream: THandleStream);
begin
  if AStream = nil then
    Exit;
  FreeAndNil(AStream);
end;

procedure TProcess.Loaded;
begin
  inherited Loaded;
  if (csDesigning in ComponentState) and (FCommandLine <> '') then
    ConvertCommandLine;
end;

procedure TProcess.CloseInput;
begin
  FreeStream(THandleStream(FInputStream));
end;

procedure TProcess.CloseOutput;
begin
  FreeStream(THandleStream(FOutputStream));
end;

procedure TProcess.CloseStderr;
begin
  FreeStream(THandleStream(FStdErrorStream));
end;

procedure TProcess.SetWindowColumns(Value: Cardinal);
begin
  if Value <> 0 then
    Include(FStartupOptions, suoUseCountChars);
  dwXCountChars := Value;
end;

procedure TProcess.SetWindowHeight(Value: Cardinal);
begin
  if Value <> 0 then
    include(FStartupOptions, suoUsePosition);
  dwYSize := Value;
end;

procedure TProcess.SetWindowLeft(Value: Cardinal);
begin
  if Value <> 0 then
    Include(FStartupOptions, suoUseSize);
  dwx := Value;
end;

procedure TProcess.SetWindowTop(Value: Cardinal);
begin
  if Value <> 0 then
    Include(FStartupOptions, suoUsePosition);
  dwy := Value;
end;

procedure TProcess.SetWindowWidth(Value: Cardinal);
begin
  if (Value <> 0) then
    Include(FStartupOptions, suoUseSize);
  dwXSize := Value;
end;

function TProcess.GetWindowRect: TRect;
begin
  with Result do
  begin
    Left := dwx;
    Right := dwx + dwxSize;
    Top := dwy;
    Bottom := dwy + dwysize;
  end;
end;

procedure TProcess.SetCommandLine(const AValue: string);
begin
  if FCommandLine = AValue then
    Exit;
  FCommandLine := AValue;
  if not (csLoading in ComponentState) then
    ConvertCommandLine;
end;

procedure TProcess.SetParameters(const AValue: TStrings);
begin
  FParameters.Assign(AValue);
end;

procedure TProcess.SetWindowRect(Value: Trect);
begin
  Include(FStartupOptions, suoUseSize);
  Include(FStartupOptions, suoUsePosition);
  with Value do
  begin
    dwx := Left;
    dwxSize := Right - Left;
    dwy := Top;
    dwySize := Bottom - top;
  end;
end;

procedure TProcess.SetWindowRows(Value: Cardinal);
begin
  if Value <> 0 then
    Include(FStartupOptions, suoUseCountChars);
  dwYCountChars := Value;
end;

procedure TProcess.SetApplicationName(const Value: string);
begin
  FApplicationName := Value;
  if (csDesigning in ComponentState) and (FCommandLine.IsEmpty) then
    FCommandLine := Value;
end;

procedure TProcess.SetProcessOptions(const Value: TProcessOptions);
begin
  FProcessOptions := Value;
  if poNewConsole in FProcessOptions then
    Exclude(FProcessOptions, poNoConsole);
  if poRunSuspended in FProcessOptions then
    Exclude(FProcessOptions, poWaitOnExit);
end;

procedure TProcess.SetActive(const Value: Boolean);
begin
  if (Value <> GetRunning) then
    if Value then
      Execute
    else
      Terminate(0);
end;

procedure TProcess.SetEnvironment(const Value: TStrings);
begin
  FEnvironment.Assign(Value);
end;

procedure TProcess.ConvertCommandLine;
begin
  FParameters.Clear;
  CommandToList(FCommandLine, FParameters);
  if FParameters.Count > 0 then
  begin
    Executable := FParameters[0];
    FParameters.Delete(0);
  end;
end;

function InternalRunCommand(Process: TProcess; out OutputString: AnsiString; out StdErrString: AnsiString; out ExitStatus: Integer): Integer;
const
  READ_BYTES = 65536; // not too small to avoid fragmentation when reading large files.
var
  NumBytes, BytesRead, Available: Integer;
  OutputLength, StdErrLength: Integer;
  StdErrNumBytes, StdErrBytesRead: Integer;
begin
  BytesRead := 0;
  OutputLength := 0;
  StdErrBytesRead := 0;
  StdErrLength := 0;
  try
    try
      Process.Options := Process.Options + [poUsePipes];
      Process.Execute;
      while Process.Running do
      begin
        // Only call ReadFromStream if Data from corresponding stream
        // is already available, otherwise, on  linux, the read call
        // is blocking, and thus it is not possible to be sure to handle
        // big data amounts bboth on output and stderr pipes. PM.
        Available := Process.Output.NumBytesAvailable;
        // writeln('DEBUG: bytesavail: ', P.Output.NumBytesAvailable);
        if Available > 0 then
        begin
          if (BytesRead + Available > OutputLength) then
          begin
            OutputLength := BytesRead + READ_BYTES;
            SetLength(OutputString, OutputLength);
          end;
          NumBytes := Process.Output.Read(OutputString[1 + BytesRead], Available);
          if NumBytes > 0 then
            Inc(BytesRead, NumBytes);
        end
        // The check for assigned(P.stderr) is mainly here so that
        // if we use poStderrToOutput in p.Options, we do not access invalid memory.
        else if Assigned(Process.StdError) and (Process.StdError.NumBytesAvailable > 0) then
        begin
          Available := Process.StdError.NumBytesAvailable;
          if StdErrBytesRead + Available > StdErrLength then
          begin
            StdErrLength := StdErrBytesRead + READ_BYTES;
            SetLength(StdErrString, StdErrLength);
          end;
          StdErrNumBytes := Process.StdError.Read(StdErrString[1 + StdErrBytesRead], Available);
          if StdErrNumBytes > 0 then
            Inc(StdErrBytesRead, StdErrNumBytes);
        end
        else
          Sleep(100);
      end;
      // Get left output after end of execution
      Available := Process.Output.NumBytesAvailable;
      while Available > 0 do
      begin
        if BytesRead + Available > OutputLength then
        begin
          OutputLength := BytesRead + READ_BYTES;
          SetLength(OutputString, OutputLength);
        end;
        NumBytes := Process.Output.Read(OutputString[1 + BytesRead], Available);
        if NumBytes > 0 then
          Inc(BytesRead, NumBytes);
        Available := Process.Output.NumBytesAvailable;
      end;
      SetLength(OutputString, BytesRead);
      while Assigned(Process.StdError) and (Process.StdError.NumBytesAvailable > 0) do
      begin
        Available := Process.StdError.NumBytesAvailable;
        if StdErrBytesRead + Available > StdErrLength then
        begin
          StdErrLength := StdErrBytesRead + READ_BYTES;
          SetLength(StdErrString, StdErrLength);
        end;
        StdErrNumBytes := Process.StdError.Read(StdErrString[1 + StdErrBytesRead], Available);
        if StdErrNumBytes > 0 then
          Inc(StdErrBytesRead, StdErrNumBytes);
      end;
      SetLength(StdErrString, StdErrBytesRead);
      ExitStatus := Process.ExitStatus;
      Result := 0; // we came to here, document that.
    except
      on E: Exception do
      begin
        Result := 1;
        SetLength(OutputString, BytesRead);
      end;
    end;
  finally
    Process.Free;
  end;
end;

const
  ForbiddenOptions =[poRunSuspended, poWaitOnExit];

function RunCommandIndir(const CurDir: string; const ExeName: string; const Commands: array of string; out OutputString: AnsiString; out ExitStatus: integer; Options: TProcessOptions = []): integer;
var
  Process: TProcess;
  ErrorString: AnsiString;
begin
  Process := TProcess.Create(nil);
  if Options <> [] then
    Process.Options := Options - ForbiddenOptions;
  Process.Executable := ExeName;
  if CurDir <> '' then
    Process.CurrentDirectory := CurDir;
  Process.Parameters.AddStrings(Commands);
  Result := InternalRunCommand(Process, OutputString, ErrorString, ExitStatus);
end;

function RunCommandInDir(const CurDir, CmdLine: string; out OutputString: AnsiString): Boolean; deprecated;
var
  Process: TProcess;
  ExitStatus: Integer;
  ErrorString: AnsiString;
begin
  Process := TProcess.Create(nil);
  Process.SetCommandLine(CmdLine);
  if CurDir <> '' then
    Process.CurrentDirectory := CurDir;
  Result := (InternalRunCommand(Process, OutputString, ErrorString, ExitStatus) = 0) and (ExitStatus = 0);
end;

function RunCommandIndir(const CurDir: string; const ExeName: string; const Commands: array of string; out OutputString: AnsiString; Options: TProcessOptions = []): Boolean;
var
  Process: TProcess;
  ExitStatus: Integer;
  ErrorString: AnsiString;
begin
  Process := TProcess.Create(nil);
  if Options <> [] then
    Process.Options := Options - ForbiddenOptions;
  Process.Executable := ExeName;
  if CurDir <> '' then
    Process.CurrentDirectory := CurDir;
  Process.Parameters.AddStrings(Commands);
  Result := (InternalRunCommand(Process, OutputString, ErrorString, ExitStatus) = 0) and (ExitStatus = 0);
end;

function RunCommand(const CmdLine: string; out OutputString: AnsiString): Boolean; deprecated;
var
  Process: TProcess;
  ExitStatus: Integer;
  ErrorString: AnsiString;
begin
  Process := TProcess.Create(nil);
  Process.SetCommandLine(CmdLine);
  Result := (InternalRunCommand(Process, OutputString, ErrorString, ExitStatus) = 0) and (ExitStatus = 0);
end;

function RunCommand(const ExeName: string; const Commands: array of string; out OutputString: AnsiString; Options: TProcessOptions = []): Boolean;
var
  Process: TProcess;
  ExitStatus: Integer;
  ErrorString: AnsiString;
begin
  Process := TProcess.Create(nil);
  if Options <> [] then
    Process.Options := Options - ForbiddenOptions;
  Process.Executable := ExeName;
  Process.Parameters.AddStrings(Commands);
  Result := (InternalRunCommand(Process, OutputString, ErrorString, ExitStatus) = 0) and (ExitStatus = 0);
end;

end.

