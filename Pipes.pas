{
This file is part of the Free Pascal run time library.
Copyright (c) 1999-2000 by Michael Van Canneyt

Implementation of pipe stream.

See the file COPYING.FPC, included in this distribution,
for details about the copyright.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}


unit Pipes;

interface

uses
  System.Types, System.SysUtils, System.Classes;

type
  EPipeError = class(EStreamError);

  EPipeSeek = class(EPipeError);

  EPipeCreation = class(EPipeError);

  { TInputPipeStream }

  TInputPipeStream = class(THandleStream)
  private
    FPos: Int64;
    function GetNumBytesAvailable: Cardinal;
    procedure WriteNotImplemented;
    procedure FakeSeekForward(Offset: Int64; const Origin: TSeekOrigin; const Pos: Int64);
    procedure DiscardLarge(Count: Int64; const MaxBufferSize: Longint);
    procedure Discard(const Count: Int64);
  protected
    function GetPosition: Int64;
    procedure InvalidSeek;
  public
    destructor Destroy; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    property NumBytesAvailable: Cardinal read GetNumBytesAvailable;
  end;

  TOutputPipeStream = class(THandleStream)
  private
    procedure ReadNotImplemented;
    procedure InvalidSeek;
  public
    destructor Destroy; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    function Read(var Buffer; Count: Longint): Longint; override;
  end;

function CreatePipeHandles(var Inhandle, OutHandle: THandle; APipeBufferSize: Cardinal = 1024): Boolean;

procedure CreatePipeStreams(var InPipe: TInputPipeStream; var OutPipe: TOutputPipeStream);

const
  EPipeMsg = 'Failed to create pipe.';
  ENoSeekMsg = 'Cannot seek on pipes';

implementation

{$IFDEF MACOS}
  //need implement
{$ENDIF}

{$IFDEF MSWINDOWS}

uses
  Winapi.Windows;

type
  PSecurityAttributes = ^TSecurityAttributes;

  TSecurityAttributes = record
    nLength: DWORD;
    lpSecurityDescriptor: Pointer;
    bInheritHandle: BOOL;
  end;

const
  piInheritablePipe: TSecurityAttributes = (
    nlength: SizeOF(TSecurityAttributes);
    lpSecurityDescriptor: nil;
    Binherithandle: True
  );
  piNonInheritablePipe: TSecurityAttributes = (
    nlength: SizeOF(TSecurityAttributes);
    lpSecurityDescriptor: nil;
    Binherithandle: False
  );
  PipeBufSize = 1024;

function CreatePipeHandles(var InHandle, OutHandle: THandle; APipeBufferSize: Cardinal = PipeBufSize): Boolean;
begin
  Result := CreatePipe(InHandle, OutHandle, @piNonInheritablePipe, APipeBufferSize);
  //writeln('DEBUG: createpipe result: ', result);
end;

function TInputPipeStream.GetNumBytesAvailable: Cardinal;
begin
  if not PeekNamedPipe(Handle, nil, 0, nil, @Result, nil) then
    Result := 0;
end;

function TInputPipeStream.GetPosition: Int64;
begin
  Result := FPos;
end;

procedure TInputPipeStream.InvalidSeek;
begin
  raise EPipeSeek.Create(ENoSeekMsg);
end;

procedure PipeClose(const Handle: THandle); inline;
begin
  FileClose(Handle);
end;
{$ENDIF}

procedure CreatePipeStreams(var InPipe: TInputPipeStream; var OutPipe: TOutputPipeStream);
var
  InHandle, OutHandle: THandle;
begin
  if CreatePipeHandles(InHandle, OutHandle) then
  begin
    InPipe := TInputPipeStream.Create(InHandle);
    OutPipe := TOutputPipeStream.Create(OutHandle);
  end
  else
    raise EPipeCreation.Create(EPipeMsg)
end;

destructor TInputPipeStream.Destroy;
begin
  PipeClose(Handle);
  inherited;
end;

procedure TInputPipeStream.DiscardLarge(Count: Int64; const MaxBufferSize: Longint);
var
  Buffer: array of Byte;
begin
  if Count = 0 then
    Exit;
  if Count > MaxBufferSize then
    SetLength(Buffer, MaxBufferSize)
  else
    SetLength(Buffer, Count);
  while (Count >= Length(Buffer)) do
  begin
    ReadBuffer(Buffer[0], Length(Buffer));
    Dec(Count, Length(Buffer));
  end;
  if Count > 0 then
    ReadBuffer(Buffer[0], Count);
end;

procedure TInputPipeStream.Discard(const Count: Int64);
const
  CSmallSize = 255;
  CLargeMaxBuffer = 32 * 1024;
var
  Buffer: array[1..CSmallSize] of Byte;
begin
  if Count = 0 then
    Exit;
  if Count <= SizeOf(Buffer) then
    ReadBuffer(Buffer, Count)
  else
    DiscardLarge(Count, CLargeMaxBuffer);
end;

procedure TInputPipeStream.FakeSeekForward(Offset: Int64; const Origin: TSeekOrigin; const Pos: Int64);
begin
  if Origin = soBeginning then
    Dec(Offset, Pos);
  if (Offset < 0) or (Origin = soEnd) then
    InvalidSeek;
  if Offset > 0 then
    Discard(Offset);
end;

procedure TInputPipeStream.WriteNotImplemented;
begin
  raise EStreamError.CreateFmt('Cannot write to this stream, not implemented', []);
end;

procedure TOutputPipeStream.ReadNotImplemented;
begin
  raise EStreamError.CreateFmt('Cannot read from this stream, not implemented', []);
end;

function TInputPipeStream.Write(const Buffer; Count: Longint): longint;
begin
  WriteNotImplemented;
  Result := 0;
end;

function TInputPipeStream.Read(var Buffer; Count: Longint): longint;
begin
  Result := inherited Read(Buffer, Count);
  Inc(FPos, Result);
end;

function TInputPipeStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  FakeSeekForward(Offset, Origin, FPos);
  Result := FPos;
end;

destructor TOutputPipeStream.Destroy;
begin
  PipeClose(Handle);
  inherited;
end;

function TOutputPipeStream.Read(var Buffer; Count: Longint): longint;
begin
  ReadNotImplemented;
  Result := 0;
end;

procedure TOutputPipeStream.InvalidSeek;
begin
  raise EStreamError.CreateFmt('Invalid seek in TProcess', []);
end;

function TOutputPipeStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  Result := 0; { to silence warning mostly }
  InvalidSeek;
end;

end.

