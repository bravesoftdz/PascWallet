unit ufrmpascwallet;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{ PascWallet (PAWA) for PascalCoin is a simple GUI build on the original PascalCoin
  source code. PascWallet is copyright (c) 2017 by Björn Biermann Madsen.
  If you like it, consider a donation using PascalCoin Account: 184992-76


  PascalCoin is copyright (c) 2016 by Albert Molina

  Distributed under the MIT software license, see the accompanying file LICENSE
  or visit http://www.opensource.org/licenses/mit-license.php.

  This unit is a part of Pascal Coin, a P2P crypto currency without need of
  historical operations.

  If you like it, consider a donation using BitCoin:
  16K3HCZRhFUtM8GdWRcfKeaa6KsuyxZaYk

  }

interface

{$I ../Units/PascalCoin/config.inc}

uses
{$IFnDEF FPC}
  pngimage, Windows, AppEvnts, ShlObj,
{$ELSE}
  LCLIntf, LCLType, LMessages,
{$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, UWalletKeys, StdCtrls,
  ULog, Grids, UAppParams, UOpTransaction,
  UBlockChain, UNode, UGridUtils, UAccounts, Menus, ImgList,
  UNetProtocol, UCrypto, Buttons, UPoolMining, URPC, UFRMAccountSelect;

Const
  CM_PC_WalletKeysChanged = WM_USER + 1;
  CM_PC_NetConnectionUpdated = WM_USER + 2;
  PW_Version  = '0.2a - ALFA TEST';

type
  TMinerPrivateKey = (mpk_NewEachTime, mpk_Random, mpk_Selected);

  { Tfrmpascwallet }

  Tfrmpascwallet = class(TForm)
    btSendCancel: TBitBtn;
    btSendExec: TBitBtn;
    dgAccountOperations: TDrawGrid;
    edSendAcc: TEdit;
    edSendBal: TEdit;
    edRecvAcc: TEdit;
    edSendAmount: TEdit;
    edSendFee: TEdit;
    lbErr: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    mmSendMsg: TMemo;
    pnlTop: TPanel;
    Image1: TImage;
    rbUencode: TRadioButton;
    rbEncode: TRadioButton;
    sbSearchAccount: TSpeedButton;
    sbRecvAcc: TSpeedButton;
    StatusBar: TStatusBar;
    PageControl: TPageControl;
    tsPayment: TTabSheet;
    tsMyAccounts: TTabSheet;
    TimerUpdateStatus: TTimer;
    tsLogs: TTabSheet;
    pnlTopLogs: TPanel;
    cbShowDebugLogs: TCheckBox;
    memoLogs: TMemo;
    pnlMyAccountsTop: TPanel;
    dgAccounts: TDrawGrid;
    cbMyPrivateKeys: TComboBox;
    Splitter1: TSplitter;
    MainMenu: TMainMenu;
    miProject: TMenuItem;
    miOptions: TMenuItem;
    miPrivatekeys: TMenuItem;
    miN1: TMenuItem;
    miAbout: TMenuItem;
    miAboutPascalCoin: TMenuItem;
    miNewOperation: TMenuItem;
    lblCurrentBlockCaption: TLabel;
    lblCurrentBlock: TLabel;
    lblCurrentBlockTimeCaption: TLabel;
    lblCurrentBlockTime: TLabel;
    Label8: TLabel;
    lblNodeStatus: TLabel;
    cbExploreMyAccounts: TCheckBox;
    N1: TMenuItem;
    MiClose: TMenuItem;
    MiDecodePayload: TMenuItem;
    ImageListIcons: TImageList;
    ApplicationEvents: {$IFDEF FPC}TApplicationProperties{$ELSE}TApplicationEvents{$ENDIF};
    pnlAccounts: TPanel;
    pnlAccountsInfo: TPanel;
    Label17: TLabel;
    Label19: TLabel;
    lblAccountsCount: TLabel;
    lblAccountsBalance: TLabel;
    lblBuild: TLabel;
    ebFindAccountNumber: TEdit;
    Label18: TLabel;
    IPnodes1: TMenuItem;
    bbChangeKeyName: TBitBtn;
    pcAccountsOptions: TPageControl;
    tsAccountOperations: TTabSheet;
    MiOperations: TMenuItem;
    MiFindaccount: TMenuItem;
    bbAccountsRefresh: TBitBtn;
    MiFindOperationbyOpHash: TMenuItem;
    MiAccountInformation: TMenuItem;
    procedure btSendCancelClick(Sender: TObject);
    procedure btSendExecClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sbRecvAccClick(Sender: TObject);
    procedure sbSearchAccountClick(Sender: TObject);
    procedure TimerUpdateStatusTimer(Sender: TObject);
    procedure cbMyPrivateKeysChange(Sender: TObject);
    procedure dgAccountsClick(Sender: TObject);
    procedure miOptionsClick(Sender: TObject);
    procedure miAboutPascalCoinClick(Sender: TObject);
    procedure miNewOperationClick(Sender: TObject);
    procedure miPrivatekeysClick(Sender: TObject);
    procedure dgAccountsColumnMoved(Sender: TObject; FromIndex,
      ToIndex: Integer);
    procedure dgAccountsFixedCellClick(Sender: TObject; ACol, ARow: Integer);
    procedure PageControlChange(Sender: TObject);
    procedure cbExploreMyAccountsClick(Sender: TObject);
    procedure MiCloseClick(Sender: TObject);
    procedure MiDecodePayloadClick(Sender: TObject);
    procedure ApplicationEventsMinimize(Sender: TObject);
    procedure ebFindAccountNumberChange(Sender: TObject);
    procedure ebFindAccountNumberExit(Sender: TObject);
    procedure IPnodes1Click(Sender: TObject);
    procedure bbChangeKeyNameClick(Sender: TObject);
    procedure sbSelectedAccountsAddClick(Sender: TObject);
    procedure sbSelectedAccountsAddAllClick(Sender: TObject);
    procedure sbSelectedAccountsDelAllClick(Sender: TObject);
    procedure bbSelectedAccountsOperationClick(Sender: TObject);
    procedure MiAddaccounttoSelectedClick(Sender: TObject);
    procedure MiMultiaccountoperationClick(Sender: TObject);
    procedure MiFindnextaccountwithhighbalanceClick(Sender: TObject);
    procedure MiFindpreviousaccountwithhighbalanceClick(Sender: TObject);
    procedure MiFindaccountClick(Sender: TObject);
    procedure bbAccountsRefreshClick(Sender: TObject);
    procedure MiFindOperationbyOpHashClick(Sender: TObject);
    procedure MiAccountInformationClick(Sender: TObject);
  private
    FBackgroundPanel : TPanel;
    FMinersBlocksFound: Integer;
    Procedure CheckIsReady;
    Procedure FinishedLoadingApp;
    Procedure FillAccountInformation(Const Strings : TStrings; Const AccountNumber : Cardinal);
    Procedure FillOperationInformation(Const Strings : TStrings; Const OperationResume : TOperationResume);
  protected
    { Private declarations }
    FNode : TNode;
    FIsActivated : Boolean;
    FWalletKeys : TWalletKeysExt;
    FLog : TLog;
    FAppParams : TAppParams;
    FNodeNotifyEvents : TNodeNotifyEvents;
    FAccountsGrid : TAccountsGrid;
    FSelectedAccountsGrid : TAccountsGrid;
    FOperationsAccountGrid : TOperationsGrid;
    FPendingOperationsGrid : TOperationsGrid;
    FOrderedAccountsKeyList : TOrderedAccountKeysList;
    FOperationsExplorerGrid : TOperationsGrid;
    FBlockChainGrid : TBlockChainGrid;
    FMinerPrivateKeyType : TMinerPrivateKey;
    FUpdating : Boolean;
    FMessagesUnreadCount : Integer;
    FMinAccountBalance : Int64;
    FMaxAccountBalance : Int64;
    FPoolMiningServer : TPoolMiningServer;
    FRPCServer : TRPCServer;
    FMustProcessWalletChanged : Boolean;
    FMustProcessNetConnectionUpdated : Boolean;
    Procedure OnNewAccount(Sender : TObject);
    Procedure OnReceivedHelloMessage(Sender : TObject);
    Procedure OnNetStatisticsChanged(Sender : TObject);
    procedure OnNewLog(logtype : TLogType; Time : TDateTime; ThreadID : Cardinal; Const sender, logtext : AnsiString);
    procedure OnWalletChanged(Sender : TObject);
    procedure OnNetConnectionsUpdated(Sender : TObject);
    Procedure OnMiningServerNewBlockFound(Sender : TObject);
    Procedure UpdateConnectionStatus;
    Procedure UpdateAccounts(RefreshData : Boolean);
    Procedure UpdateBlockChainState;
    Procedure UpdatePrivateKeys;
    Procedure UpdateOperations;
    Procedure LoadAppParams;
    Procedure SaveAppParams;
    Procedure UpdateConfigChanged;
    Procedure UpdateNodeStatus;
    procedure Activate; override;
    Function ForceMining : Boolean; virtual;
    Function GetAccountKeyForMiner : TAccountKey;
    Procedure DoUpdateAccounts;
    procedure CM_WalletChanged(var Msg: TMessage); message CM_PC_WalletKeysChanged;
    procedure UpdatePayment(acc: int64);
  public
    { Public declarations }
    Property WalletKeys : TWalletKeysExt read FWalletKeys;
  end;

var
  frmpascwallet: Tfrmpascwallet;

implementation

{$IFnDEF FPC}
  {$R *.lfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

Uses UFolderHelper, UOpenSSL, UOpenSSLdef, UConst, UTime, UFileStorage,
  UThread, UECIES, UFRMPascalCoinWalletConfig,
  UFRMAbout, UFRMOperation, UFRMWalletKeys, UFRMPayloadDecoder, UFRMNodesIp, UFRMMemoText;

Type
  TThreadActivate = Class(TPCThread)
  protected
    procedure BCExecute; override;
  End;

{ TThreadActivate }

procedure TThreadActivate.BCExecute;
begin
  // Read Operations saved from disk
  TNode.Node.Bank.DiskRestoreFromOperations(CT_MaxBlock);
  TNode.Node.AutoDiscoverNodes(CT_Discover_IPs);
  TNode.Node.NetServer.Active := true;
  Synchronize( frmpascwallet.DoUpdateAccounts );
  Synchronize( frmpascwallet.FinishedLoadingApp );
end;

{ Tfrmpascwallet }

procedure Tfrmpascwallet.Activate;
Var ips : AnsiString;
  nsarr : TNodeServerAddressArray;
begin
  inherited;
  if FIsActivated then exit;
  FIsActivated := true;
  try
    // Check OpenSSL dll
    if Not LoadSSLCrypt then raise Exception.Create('Cannot load '+SSL_C_LIB+#10+'To use this software make sure this file is available on you system or reinstall the application');
    TCrypto.InitCrypto;
    // Read Wallet
    Try
      FWalletKeys.WalletFileName := TFolderHelper.GetPascalCoinDataFolder+PathDelim+'WalletKeys.dat';
    Except
      On E:Exception do begin
        E.Message := 'Cannot open your wallet... Perhaps another instance of Pascal Coin is active!'+#10+#10+E.Message;
        Raise;
      end;
    End;
    ips := FAppParams.ParamByName[CT_PARAM_TryToConnectOnlyWithThisFixedServers].GetAsString('');
    TNode.DecodeIpStringToNodeServerAddressArray(ips,nsarr);
    TNetData.NetData.DiscoverFixedServersOnly(nsarr);
    setlength(nsarr,0);
    // Creating Node:
    FNode := TNode.Node;
    FNode.NetServer.Port := FAppParams.ParamByName[CT_PARAM_InternetServerPort].GetAsInteger(CT_NetServer_Port);
    FNode.PeerCache := FAppParams.ParamByName[CT_PARAM_PeerCache].GetAsString('')+';'+CT_Discover_IPs;
    // Create RPC server
    FRPCServer := TRPCServer.Create;
    FRPCServer.WalletKeys := WalletKeys;
    FRPCServer.Active := FAppParams.ParamByName[CT_PARAM_JSONRPCEnabled].GetAsBoolean(false);
    FRPCServer.ValidIPs := FAppParams.ParamByName[CT_PARAM_JSONRPCAllowedIPs].GetAsString('127.0.0.1');
    WalletKeys.SafeBox := FNode.Bank.SafeBox;
    // Check Database
    FNode.Bank.StorageClass := TFileStorage;
    TFileStorage(FNode.Bank.Storage).DatabaseFolder := TFolderHelper.GetPascalCoinDataFolder+PathDelim+'Data';
    TFileStorage(FNode.Bank.Storage).Initialize;
    // Init Grid
    //FAccountsGrid.Node := FNode;
    FSelectedAccountsGrid.Node := FNode;
    FWalletKeys.OnChanged := OnWalletChanged;
    FAccountsGrid.Node := FNode;
    FOperationsAccountGrid.Node := FNode;
    // Reading database
    TThreadActivate.Create(false).FreeOnTerminate := true;
    FNodeNotifyEvents.Node := FNode;
    // Init
    TNetData.NetData.OnReceivedHelloMessage := OnReceivedHelloMessage;
    TNetData.NetData.OnStatisticsChanged := OnNetStatisticsChanged;
    TNetData.NetData.OnNetConnectionsUpdated := onNetConnectionsUpdated;
    //
    TimerUpdateStatus.Interval := 1000;
    TimerUpdateStatus.Enabled := true;
    UpdateConfigChanged;
  Except
    On E:Exception do begin
      E.Message := 'An error occurred during initialization. Application cannot continue:'+#10+#10+E.Message+#10+#10+'Application will close...';
      Application.MessageBox(PChar(E.Message),PChar(Application.Title),MB_ICONERROR+MB_OK);
      Halt;
    end;
  end;
  UpdatePrivateKeys;
  UpdateAccounts(false);
  if FAppParams.ParamByName[CT_PARAM_FirstTime].GetAsBoolean(true) then begin
    FAppParams.ParamByName[CT_PARAM_FirstTime].SetAsBoolean(false);
    miAboutPascalCoinClick(Nil);
  end;

end;

procedure Tfrmpascwallet.ApplicationEventsMinimize(Sender: TObject);
begin
  {$IFnDEF FPC}
  Hide();
  WindowState := wsMinimized;
  TimerUpdateStatus.Enabled := false;
  { Show the animated tray icon and also a hint balloon. }
  TrayIcon.Visible := True;
  TrayIcon.ShowBalloonHint;
  {$ENDIF}
end;

procedure Tfrmpascwallet.bbAccountsRefreshClick(Sender: TObject);
begin
  UpdateAccounts(true);
end;

procedure Tfrmpascwallet.bbChangeKeyNameClick(Sender: TObject);
var i : Integer;
  name : String;
begin
  if (cbMyPrivateKeys.ItemIndex<0) then  exit;
  i := PtrInt(cbMyPrivateKeys.Items.Objects[cbMyPrivateKeys.ItemIndex]);
  if (i<0) Or (i>=FWalletKeys.Count) then raise Exception.Create('Must select a Key');
  name := FWalletKeys.Key[i].Name;
  if InputQuery('Change Key name','Input new name',name) then begin
    FWalletKeys.SetName(i,name);
  end;
  UpdatePrivateKeys;
end;

procedure Tfrmpascwallet.bbSelectedAccountsOperationClick(Sender: TObject);
var l : TOrderedCardinalList;
begin
  CheckIsReady;
  if FSelectedAccountsGrid.AccountsCount<=0 then raise Exception.Create('Must select at least 1 account');
  With TFRMOperation.Create(Self) do
  Try
    l := FSelectedAccountsGrid.LockAccountsList;
    try
      SenderAccounts.CopyFrom(l);
    finally
      FSelectedAccountsGrid.UnlockAccountsList;
    end;
    DefaultFee := FAppParams.ParamByName[CT_PARAM_DefaultFee].GetAsInt64(0);
    WalletKeys := FWalletKeys;
    ShowModal;
  Finally
    Free;
  End;
end;

procedure Tfrmpascwallet.cbExploreMyAccountsClick(Sender: TObject);
begin
  cbMyPrivateKeys.Enabled := cbExploreMyAccounts.Checked;
  UpdateAccounts(true);
  UpdateOperations;
end;

procedure Tfrmpascwallet.cbMyPrivateKeysChange(Sender: TObject);
begin
  UpdateAccounts(true);
end;

procedure Tfrmpascwallet.CheckIsReady;
Var isready : AnsiString;
begin
  if Not Assigned(FNode) then Abort;

  if Not FNode.IsReady(isready) then begin
    Raise Exception.Create('You cannot do this operation now:'+#10+#10+isready);
  end;
end;

procedure Tfrmpascwallet.CM_WalletChanged(var Msg: TMessage);
begin
  UpdatePrivateKeys;
  FMustProcessWalletChanged := false;
end;

procedure Tfrmpascwallet.dgAccountsClick(Sender: TObject);
begin
  UpdateOperations;
end;

procedure Tfrmpascwallet.dgAccountsColumnMoved(Sender: TObject; FromIndex, ToIndex: Integer);
begin
  SaveAppParams;
end;

procedure Tfrmpascwallet.dgAccountsFixedCellClick(Sender: TObject; ACol,
  ARow: Integer);
begin
  SaveAppParams;
end;

procedure Tfrmpascwallet.DoUpdateAccounts;
begin
  UpdateAccounts(true);
end;

procedure Tfrmpascwallet.ebFindAccountNumberChange(Sender: TObject);
Var an : Cardinal;
begin
  if Trim(ebFindAccountNumber.Text)='' then begin
    ebFindAccountNumber.Color := clWindow;
    ebFindAccountNumber.Font.Color := clDkGray;
  end else if TAccountComp.AccountTxtNumberToAccountNumber(ebFindAccountNumber.Text,an) then begin
    ebFindAccountNumber.Color := clWindow;
    if FAccountsGrid.MoveRowToAccount(an) then begin
      ebFindAccountNumber.Font.Color := clWindowText;
    end else begin
      ebFindAccountNumber.Font.Color := clRed;
    end;
  end else begin
    // Invalid value
    ebFindAccountNumber.Color := clRed;
    ebFindAccountNumber.Font.Color := clWindowText;
  end;
end;

procedure Tfrmpascwallet.ebFindAccountNumberExit(Sender: TObject);
begin
  ebFindAccountNumber.Text := '';
end;

procedure Tfrmpascwallet.FinishedLoadingApp;
begin
  FPoolMiningServer := TPoolMiningServer.Create;
  FPoolMiningServer.Port := FAppParams.ParamByName[CT_PARAM_JSONRPCMinerServerPort].GetAsInteger(CT_JSONRPCMinerServer_Port);
  FPoolMiningServer.MinerAccountKey := GetAccountKeyForMiner;
  FPoolMiningServer.MinerPayload := FAppParams.ParamByName[CT_PARAM_MinerName].GetAsString('');
  FNode.Operations.AccountKey := GetAccountKeyForMiner;
  FPoolMiningServer.Active := FAppParams.ParamByName[CT_PARAM_JSONRPCMinerServerActive].GetAsBoolean(true);
  FPoolMiningServer.OnMiningServerNewBlockFound := OnMiningServerNewBlockFound;
  If Assigned(FBackgroundPanel) then begin
    FreeAndNil(FBackgroundPanel);
  end;
  PageControl.Visible:=True;
  PageControl.Enabled:=True;
end;

procedure Tfrmpascwallet.FillAccountInformation(const Strings: TStrings; Const AccountNumber: Cardinal);
Var account : TAccount;
  s : String;
begin
  if AccountNumber<0 then exit;
  account := FNode.Operations.SafeBoxTransaction.Account(AccountNumber);
  if account.name<>'' then s:='Name: '+account.name
  else s:='';
  Strings.Add(Format('Account: %s %s Type:%d',[TAccountComp.AccountNumberToAccountTxtNumber(AccountNumber),s,account.account_type]));
  Strings.Add('');
  Strings.Add(Format('Current balance: %s',[TAccountComp.FormatMoney(account.balance)]));
  Strings.Add('');
  Strings.Add(Format('Updated on block: %d  (%d blocks ago)',[account.updated_block,FNode.Bank.BlocksCount-account.updated_block]));
  Strings.Add(Format('Public key type: %s',[TAccountComp.GetECInfoTxt(account.accountInfo.accountKey.EC_OpenSSL_NID)]));
  Strings.Add(Format('Base58 Public key: %s',[TAccountComp.AccountPublicKeyExport(account.accountInfo.accountKey)]));
  if TAccountComp.IsAccountForSale(account.accountInfo) then begin
    Strings.Add('');
    Strings.Add('** Account is for sale: **');
    Strings.Add(Format('Price: %s',[TAccountComp.FormatMoney(account.accountInfo.price)]));
    Strings.Add(Format('Seller account (where to pay): %s',[TAccountComp.AccountNumberToAccountTxtNumber(account.accountInfo.account_to_pay)]));
    if TAccountComp.IsAccountForSaleAcceptingTransactions(account.accountInfo) then begin
      Strings.Add('');
      Strings.Add('** Private sale **');
      Strings.Add(Format('New Base58 Public key: %s',[TAccountComp.AccountPublicKeyExport(account.accountInfo.new_publicKey)]));
      Strings.Add('');
      if TAccountComp.IsAccountLocked(account.accountInfo,FNode.Bank.BlocksCount) then begin
        Strings.Add(Format('PURCHASE IS SECURE UNTIL BLOCK %d (current %d, remains %d)',
          [account.accountInfo.locked_until_block,FNode.Bank.BlocksCount,account.accountInfo.locked_until_block-FNode.Bank.BlocksCount]));
      end else begin
        Strings.Add(Format('PURCHASE IS NOT SECURE (Expired on block %d, current %d)',
          [account.accountInfo.locked_until_block,FNode.Bank.BlocksCount]));
      end;
    end;
  end;
end;

procedure Tfrmpascwallet.FillOperationInformation(const Strings: TStrings; Const OperationResume: TOperationResume);
begin
  If (not OperationResume.valid) then exit;
  If OperationResume.Block<FNode.Bank.BlocksCount then
    if (OperationResume.NOpInsideBlock>=0) then begin
      Strings.Add(Format('Block: %d/%d',[OperationResume.Block,OperationResume.NOpInsideBlock]))
    end else begin
      Strings.Add(Format('Block: %d',[OperationResume.Block]))
    end
  else Strings.Add('** Pending operation not included on blockchain **');
  Strings.Add(Format('%s',[OperationResume.OperationTxt]));
  Strings.Add(Format('OpType:%d Subtype:%d',[OperationResume.OpType,OperationResume.OpSubtype]));
  Strings.Add(Format('Operation Hash (ophash): %s',[TCrypto.ToHexaString(OperationResume.OperationHash)]));
  If (OperationResume.OperationHash_OLD<>'') then begin
    Strings.Add(Format('Old Operation Hash (old_ophash): %s',[TCrypto.ToHexaString(OperationResume.OperationHash_OLD)]));
  end;
  if (OperationResume.OriginalPayload<>'') then begin
    Strings.Add(Format('Payload length:%d',[length(OperationResume.OriginalPayload)]));
    If OperationResume.PrintablePayload<>'' then begin
      Strings.Add(Format('Payload (human): %s',[OperationResume.PrintablePayload]));
    end;
    Strings.Add(Format('Payload (Hexadecimal): %s',[TCrypto.ToHexaString(OperationResume.OriginalPayload)]));
  end;
  If OperationResume.Balance>=0 then begin
    Strings.Add(Format('Final balance: %s',[TAccountComp.FormatMoney(OperationResume.Balance)]));
  end;
end;

function Tfrmpascwallet.ForceMining: Boolean;
begin
  Result := false;
end;

procedure Tfrmpascwallet.FormCreate(Sender: TObject);
Var i : Integer;
begin
  FBackgroundPanel := Nil;
  FMustProcessWalletChanged := false;
  FMustProcessNetConnectionUpdated := false;
  FRPCServer := Nil;
  FNode := Nil;
  FPoolMiningServer := Nil;
  FMinAccountBalance := 0;
  FMaxAccountBalance := CT_MaxWalletAmount;
  FMessagesUnreadCount := 0;
  FUpdating := false;
  FOrderedAccountsKeyList := Nil;
  TimerUpdateStatus.Enabled := false;
  FIsActivated := false;
  FWalletKeys := TWalletKeysExt.Create(Self);
  for i := 0 to StatusBar.Panels.Count - 1 do begin
    StatusBar.Panels[i].Text := '';
  end;
  FLog := TLog.Create(Self);
  FLog.OnNewLog := OnNewLog;
  FLog.SaveTypes := [];
  If Not ForceDirectories(TFolderHelper.GetPascalCoinDataFolder) then raise Exception.Create('Cannot create dir: '+TFolderHelper.GetPascalCoinDataFolder);
  FAppParams := TAppParams.Create(self);
  FAppParams.FileName := TFolderHelper.GetPascalCoinDataFolder+PathDelim+'AppParams.prm';
  FNodeNotifyEvents := TNodeNotifyEvents.Create(Self);
  FNodeNotifyEvents.OnBlocksChanged := OnNewAccount;
  FAccountsGrid := TAccountsGrid.Create(Self);
  FAccountsGrid.DrawGrid := dgAccounts;
  FAccountsGrid.AllowMultiSelect := True;
  FSelectedAccountsGrid := TAccountsGrid.Create(Self);
  FOperationsAccountGrid := TOperationsGrid.Create(Self);
  FOperationsAccountGrid.DrawGrid := dgAccountOperations;
  FOperationsAccountGrid.MustShowAlwaysAnAccount := true;
  FPendingOperationsGrid := TOperationsGrid.Create(Self);
  FPendingOperationsGrid.AccountNumber := -1; // all
  FPendingOperationsGrid.PendingOperations := true;
  FOperationsExplorerGrid := TOperationsGrid.Create(Self);
  FOperationsExplorerGrid.AccountNumber := -1;
  FOperationsExplorerGrid.PendingOperations := False;
  FBlockChainGrid := TBlockChainGrid.Create(Self);
  FWalletKeys.OnChanged := OnWalletChanged;
  LoadAppParams;
  UpdatePrivateKeys;
  UpdateBlockChainState;
  UpdateConnectionStatus;
  PageControl.ActivePage := tsMyAccounts;
  pcAccountsOptions.ActivePage := tsPayment;
  cbExploreMyAccountsClick(nil);

  lblBuild.Caption := 'PascWallet: '+PW_Version;
  {$IFDEF TESTNET}
  Image1.visible := false;
  {$ENDIF}
  PageControl.Enabled := False;
  PageControl.Visible := False;
  FBackgroundPanel := TPanel.Create(Self);
  FBackgroundPanel.Parent:=Self;
  FBackgroundPanel.Align:=alClient;
  FBackgroundPanel.Font.Size:=15;
end;

//*
procedure Tfrmpascwallet.btSendCancelClick(Sender: TObject);
begin
  edRecvAcc.Text := '';
  edSendAmount.Text := '';
  edSendFee.Text := '';
  rbUencode.Checked := True;
end;

procedure Tfrmpascwallet.btSendExecClick(Sender: TObject);
Var
  _payload, errors : AnsiString;
  i : Integer;
  wk : TWalletKey;
  ops : TOperationsHashTree;
  op : TPCOperation;
  send_account : TAccount;
  operation_to_string: String;
  _amount,_fee, _bal : Int64;
  sndacc, rcvacc: Cardinal;
begin
  if Not Assigned(WalletKeys) then raise Exception.Create('No wallet keys');
  ops := TOperationsHashTree.Create;
  Try
    operation_to_string := '';
    op := Nil;

    If Not TAccountComp.AccountTxtNumberToAccountNumber(edSendAcc.Text,sndacc) then begin
      lbErr.Caption := 'Invalid sender account number';
      exit;
    end;

    if sndacc > 0 then send_account := FNode.Operations.SafeBoxTransaction.Account(sndacc); //*  temp

    i := WalletKeys.IndexOfAccountKey(send_account.accountInfo.accountkey);
    if i<0 then begin
      Raise Exception.Create('Sender account private key not found in Wallet');
    end;
    wk := WalletKeys.Key[i];

    If Not TAccountComp.AccountTxtNumberToAccountNumber(edRecvAcc.Text,rcvacc) then begin
      lbErr.Caption := 'Invalid receiver account number';
      exit;
    end;

    if not TAccountComp.TxtToMoney(edSendAmount.Text,_amount) then begin
      lbErr.Caption := 'Invalid amount ('+edSendAmount.Text+')';
      exit;
    end;

    if not TAccountComp.TxtToMoney(edSendFee.Text,_fee) then begin
      lbErr.Caption := 'Invalid amount ('+edSendFee.Text+')';
      exit;
    end;

    if not TAccountComp.TxtToMoney(edSendBal.Text,_bal) then begin
      lbErr.Caption := 'Invalid amount ('+edSendBal.Text+')';
      exit;
    end;

    if not _bal > _amount + _fee then begin
      lbErr.Caption := 'Amount + fee is more than ('+edSendBal.Text+')';  // Should never come here
      exit;
    end;

    _payload :=  mmSendMsg.Text;
    if Length(_payload) > 255 then _payload := Copy(_payload, 1, 255);

    op := TOpTransaction.CreateTransaction(send_account.account,send_account.n_operation+1,rcvacc,wk.PrivateKey,_amount,_fee,_payload);

    if Assigned(op) then begin
      ops.AddOperationToHashTree(op);
      if operation_to_string<>'' then operation_to_string := operation_to_string + #10;
        operation_to_string := operation_to_string + op.ToString;
      end;
    FreeAndNil(op);

    if (ops.OperationsCount=0) then raise Exception.Create('No valid operation to execute');

    if Application.MessageBox(PChar('Execute this operation:'+#10+#10+operation_to_string+#10+#10+'Note: This operation will be transmitted to the network!'),
        PChar(Application.Title),MB_YESNO+MB_ICONINFORMATION+MB_DEFBUTTON2)<>IdYes then exit;

    i := FNode.AddOperations(nil,ops,Nil,errors);
    if (i=ops.OperationsCount) then begin
      Application.MessageBox(PChar('Successfully executed '+inttostr(i)+' operations!'+#10+#10+operation_to_string),PChar(Application.Title),MB_OK+MB_ICONINFORMATION);
      ModalResult := MrOk;
    end else if (i>0) then begin
      Application.MessageBox(PChar('One or more of your operations has not been executed:'+#10+
        'Errors:'+#10+
        errors+#10+#10+
        'Total successfully executed operations: '+inttostr(i)),PChar(Application.Title),MB_OK+MB_ICONWARNING);
      ModalResult := MrOk;
    end else begin
      raise Exception.Create(errors);
    end;

  Finally
    ops.Free;
  End;
end;

procedure Tfrmpascwallet.FormDestroy(Sender: TObject);
Var i : Integer;
  step : String;
begin
  TLog.NewLog(ltinfo,Classname,'Destroying form - START');
  Try
  FreeAndNil(FRPCServer);
  FreeAndNil(FPoolMiningServer);
  step := 'Saving params';
  SaveAppParams;
  FreeAndNil(FAppParams);
  //
  step := 'Assigning nil events';
  FLog.OnNewLog :=Nil;
  FNodeNotifyEvents.Node := Nil;
  FOperationsAccountGrid.Node := Nil;
  FOperationsExplorerGrid.Node := Nil;
  FPendingOperationsGrid.Node := Nil;
  FAccountsGrid.Node := Nil;
  FSelectedAccountsGrid.Node := Nil;
  TNetData.NetData.OnReceivedHelloMessage := Nil;
  TNetData.NetData.OnStatisticsChanged := Nil;
  TNetData.NetData.OnNetConnectionsUpdated := Nil;
  TNetData.NetData.OnNodeServersUpdated := Nil;
  TNetData.NetData.OnBlackListUpdated := Nil;
  //

  step := 'Destroying NodeNotifyEvents';
  FreeAndNil(FNodeNotifyEvents);
  //
  step := 'Assigning Nil to TNetData';
  TNetData.NetData.OnReceivedHelloMessage := Nil;
  TNetData.NetData.OnStatisticsChanged := Nil;

  step := 'Destroying grids operators';
  FreeAndNil(FOperationsAccountGrid);
  FreeAndNil(FOperationsExplorerGrid);
  FreeAndNil(FBlockChainGrid);

  step := 'Ordered Accounts Key list';
  FreeAndNil(FOrderedAccountsKeyList);

  step := 'Desactivating Node';
  TNode.Node.NetServer.Active := false;
  FNode := Nil;

  TNetData.NetData.Free;

  step := 'Processing messages 1';
  Application.ProcessMessages;

  step := 'Destroying Node';
  TNode.Node.Free;

  step := 'Destroying Wallet';
  FreeAndNil(FWalletKeys);
  step := 'Processing messages 2';
  Application.ProcessMessages;
  step := 'Destroying stringslist';
  Except
    On E:Exception do begin
      TLog.NewLog(lterror,Classname,'Error destroying Form step: '+step+' Errors ('+E.ClassName+'): ' +E.Message);
    end;
  End;
  TLog.NewLog(ltinfo,Classname,'Destroying form - END');
  FreeAndNil(FLog);
  Sleep(100);
end;

procedure Tfrmpascwallet.sbRecvAccClick(Sender: TObject);

// procedure TFRMOperation.searchAccount(editBox: TCustomEdit);
Var F : TFRMAccountSelect;
  c : Cardinal;
begin
  F := TFRMAccountSelect.Create(Self);
  try
    F.Node := FNode;
    F.WalletKeys := FWalletKeys;
    F.Filters:=edRecvAcc.Tag;
    If TAccountComp.AccountTxtNumberToAccountNumber(edRecvAcc.Text,c) then F.DefaultAccount := c;
    F.AllowSelect:=True;
    If F.ShowModal=MrOk then begin
      edRecvAcc.Text := TAccountComp.AccountNumberToAccountTxtNumber(F.GetSelected);
    end;
  finally
    F.Free;
  end;
end;

procedure Tfrmpascwallet.sbSearchAccountClick(Sender: TObject);
Var F : TFRMAccountSelect;
begin
  F := TFRMAccountSelect.Create(Self);
  try
    F.Node := FNode;
    F.WalletKeys := FWalletKeys;
    F.ShowModal;
  finally
    F.Free;
  end;
end;

function Tfrmpascwallet.GetAccountKeyForMiner: TAccountKey;
Var PK : TECPrivateKey;
  i : Integer;
  PublicK : TECDSA_Public;
begin
  Result := CT_TECDSA_Public_Nul;
  if Not Assigned(FWalletKeys) then exit;
  if Not Assigned(FAppParams) then exit;
  case FMinerPrivateKeyType of
    mpk_NewEachTime: PublicK := CT_TECDSA_Public_Nul;
    mpk_Selected: begin
      PublicK := TAccountComp.RawString2Accountkey(FAppParams.ParamByName[CT_PARAM_MinerPrivateKeySelectedPublicKey].GetAsString(''));
    end;
  else
    // Random
    PublicK := CT_TECDSA_Public_Nul;
    if FWalletKeys.Count>0 then PublicK := FWalletKeys.Key[Random(FWalletKeys.Count)].AccountKey;
  end;
  i := FWalletKeys.IndexOfAccountKey(PublicK);
  if i>=0 then begin
    if (FWalletKeys.Key[i].CryptedKey='') then i:=-1;
  end;
  if i<0 then begin
    PK := TECPrivateKey.Create;
    try
      PK.GenerateRandomPrivateKey(CT_Default_EC_OpenSSL_NID);
      FWalletKeys.AddPrivateKey('New for miner '+DateTimeToStr(Now), PK);
      PublicK := PK.PublicKey;
    finally
      PK.Free;
    end;
  end;
  Result := PublicK;
end;

procedure Tfrmpascwallet.IPnodes1Click(Sender: TObject);
Var FRM : TFRMNodesIp;
begin
  FRM := TFRMNodesIp.Create(Self);
  Try
    FRM.AppParams := FAppParams;
    FRM.ShowModal;
  Finally
    FRM.Free;
  End;
end;

procedure Tfrmpascwallet.LoadAppParams;
Var ms : TMemoryStream;
  s : AnsiString;
  fvi : TFileVersionInfo;
begin
  ms := TMemoryStream.Create;
  Try
    s := FAppParams.ParamByName[CT_PARAM_GridAccountsStream].GetAsString('');
    ms.WriteBuffer(s[1],length(s));
    ms.Position := 0;
    // Disabled on V2: FAccountsGrid.LoadFromStream(ms);
  Finally
    ms.Free;
  End;
  If FAppParams.FindParam(CT_PARAM_MinerName)=Nil then begin
    // New configuration... assigning a new random value
    fvi := TFolderHelper.GetTFileVersionInfo(Application.ExeName);
    FAppParams.ParamByName[CT_PARAM_MinerName].SetAsString('New Node '+DateTimeToStr(Now)+' - '+
      fvi.InternalName+' Build:'+fvi.FileVersion);
  end;
  FBlockChainGrid.ShowTimeAverageColumns:={$IFDEF SHOW_AVERAGE_TIME_STATS}True;{$ELSE}False;{$ENDIF}
  UpdateConfigChanged;
end;

procedure Tfrmpascwallet.miAboutPascalCoinClick(Sender: TObject);
begin
  With TFRMAbout.Create(Self) do
  try
    showmodal;
  finally
    free;
  end;
end;

procedure Tfrmpascwallet.MiAccountInformationClick(Sender: TObject);
Var F : TFRMMemoText;
  accn : Int64;
  s,title : String;
  account : TAccount;
  strings : TStrings;
  i : Integer;
  opr : TOperationResume;
begin
  accn := -1;
  title := '';
  strings := TStringList.Create;
  try
    opr := CT_TOperationResume_NUL;
    if PageControl.ActivePage=tsMyAccounts then begin
      accn := FAccountsGrid.AccountNumber(dgAccounts.Row);
      if accn<0 then raise Exception.Create('Select an account');
      FillAccountInformation(strings,accn);
      title := 'Account '+TAccountComp.AccountNumberToAccountTxtNumber(accn)+' info';
      i := FOperationsAccountGrid.DrawGrid.Row;
      if (i>0) and (i<=FOperationsAccountGrid.OperationsResume.Count) then begin
        opr := FOperationsAccountGrid.OperationsResume.OperationResume[i-1];
      end;
    end;
    If (opr.valid) then begin
      if accn>=0 then strings.Add('')
      else title := 'Operation info';
      strings.Add('Operation info:');
      FillOperationInformation(strings,opr);
    end else if accn<0 then Raise Exception.Create('No info available');
    F := TFRMMemoText.Create(Self);
    Try
      F.Caption := title;
      F.Memo.Lines.Assign(strings);
      F.ShowModal;
    Finally
      F.Free;
    End;
  finally
    strings.free;
  end;
end;

procedure Tfrmpascwallet.MiAddaccounttoSelectedClick(Sender: TObject);
begin
  PageControl.ActivePage := tsMyAccounts;
  PageControlChange(Nil);
  sbSelectedAccountsAddClick(Sender);
end;

procedure Tfrmpascwallet.MiCloseClick(Sender: TObject);
begin
  Close;
end;

procedure Tfrmpascwallet.MiDecodePayloadClick(Sender: TObject);
begin
  if PageControl.ActivePage=tsMyAccounts then begin
    FOperationsAccountGrid.ShowModalDecoder(FWalletKeys,FAppParams);
  end;
end;

procedure Tfrmpascwallet.MiFindaccountClick(Sender: TObject);
begin
  PageControl.ActivePage := tsMyAccounts;
  PageControlChange(Nil);
  ebFindAccountNumber.SetFocus;
end;

procedure Tfrmpascwallet.MiFindnextaccountwithhighbalanceClick(Sender: TObject);
Var an  : Cardinal;
  an64 : Int64;
  start : TAccount;
begin
  PageControl.ActivePage := tsMyAccounts;
  PageControlChange(Nil);
  an64 := FAccountsGrid.AccountNumber(dgAccounts.Row);
  if an64<0 then an := 0
  else an := an64;
  If an>=FNode.Bank.SafeBox.AccountsCount then exit;
  start := FNode.Bank.SafeBox.Account(an);
  while (an<FNode.Bank.SafeBox.AccountsCount)  do begin
    if FNode.Bank.SafeBox.Account(an).balance>start.balance then break
    else inc(an);
  end;
  if (an<FNode.Bank.SafeBox.AccountsCount) then FAccountsGrid.MoveRowToAccount(an)
  else raise Exception.Create('Not found any account higher than '+TAccountComp.AccountNumberToAccountTxtNumber(start.account)+' with balance higher than '+
    TAccountComp.FormatMoney(start.balance));
end;

procedure Tfrmpascwallet.MiFindOperationbyOpHashClick(Sender: TObject);
Var FRM : TFRMPayloadDecoder;
  oph : String;
begin
  oph := '';
  if Not InputQuery('Search operation by OpHash','Insert Operation Hash value (OpHash)',oph) then exit;
  //
  FRM := TFRMPayloadDecoder.Create(Self);
  try
    FRM.Init(CT_TOperationResume_NUL,WalletKeys,FAppParams);
    FRM.DoFind(oph);
    FRM.ShowModal;
  finally
    FRM.Free;
  end;
end;

procedure Tfrmpascwallet.MiFindpreviousaccountwithhighbalanceClick(Sender: TObject);
Var an  : Cardinal;
  an64 : Int64;
  start : TAccount;
begin
  PageControl.ActivePage := tsMyAccounts;
  PageControlChange(Nil);
  an64 := FAccountsGrid.AccountNumber(dgAccounts.Row);
  if an64<0 then an := FNode.Bank.SafeBox.AccountsCount-1
  else an := an64;
  If an>=FNode.Bank.SafeBox.AccountsCount then exit;
  start := FNode.Bank.SafeBox.Account(an);
  while (an>0)  do begin
    if FNode.Bank.SafeBox.Account(an).balance>start.balance then break
    else dec(an);
  end;
  if (FNode.Bank.SafeBox.Account(an).balance>start.balance) then FAccountsGrid.MoveRowToAccount(an)
  else raise Exception.Create('Not found any account lower than '+TAccountComp.AccountNumberToAccountTxtNumber(start.account)+' with balance higher than '+
    TAccountComp.FormatMoney(start.balance));
end;

procedure Tfrmpascwallet.MiMultiaccountoperationClick(Sender: TObject);
begin
  PageControl.ActivePage := tsMyAccounts;
  bbSelectedAccountsOperationClick(Sender);
end;

procedure Tfrmpascwallet.miNewOperationClick(Sender: TObject);
var l : TOrderedCardinalList;
begin
  CheckIsReady;
  With TFRMOperation.Create(Self) do
  Try
    l := TOrderedCardinalList.Create;
    try
      If FAccountsGrid.SelectedAccounts(l)<1 then raise Exception.Create('No row selected');
      SenderAccounts.CopyFrom(l);
    finally
      l.Free;
    end;
    DefaultFee := FAppParams.ParamByName[CT_PARAM_DefaultFee].GetAsInt64(0);
    WalletKeys := FWalletKeys;
    ShowModal;
  Finally
    Free;
  End;
end;

procedure Tfrmpascwallet.miOptionsClick(Sender: TObject);
begin
  With TFRMPascalCoinWalletConfig.Create(Self) do
  try
    AppParams := Self.FAppParams;
    WalletKeys := Self.FWalletKeys;
    if ShowModal=MrOk then begin
      SaveAppParams;
      UpdateConfigChanged;
    end;
  finally
    free;
  end;
end;

procedure Tfrmpascwallet.miPrivatekeysClick(Sender: TObject);
Var FRM : TFRMWalletKeys;
begin
  FRM := TFRMWalletKeys.Create(Self);
  Try
    FRM.WalletKeys := FWalletKeys;
    FRM.ShowModal;
    UpdatePrivateKeys;
  Finally
    FRM.Free;
  End;
end;

procedure Tfrmpascwallet.OnMiningServerNewBlockFound(Sender: TObject);
begin
  FPoolMiningServer.MinerAccountKey := GetAccountKeyForMiner;
end;

procedure Tfrmpascwallet.OnNetConnectionsUpdated(Sender: TObject);
begin
  if FMustProcessNetConnectionUpdated then exit;
  FMustProcessNetConnectionUpdated := true;
  PostMessage(Self.Handle,CM_PC_NetConnectionUpdated,0,0);
end;

procedure Tfrmpascwallet.OnNetStatisticsChanged(Sender: TObject);
Var NS : TNetStatistics;
begin
  if Assigned(FNode) then begin
    If FNode.NetServer.Active then begin
      StatusBar.Panels[0].Text := 'Active (Port '+Inttostr(FNode.NetServer.Port)+')';
    end else StatusBar.Panels[0].Text := 'Server stopped';
    NS := TNetData.NetData.NetStatistics;
    StatusBar.Panels[1].Text := Format('Connections:%d Clients:%d Servers:%d - Rcvd:%d Kb Send:%d Kb',
      [NS.ActiveConnections,NS.ClientsConnections,NS.ServersConnections,NS.BytesReceived DIV 1024,NS.BytesSend DIV 1024]);
  end else begin
    StatusBar.Panels[0].Text := '';
    StatusBar.Panels[1].Text := '';
  end;
end;

procedure Tfrmpascwallet.OnNewAccount(Sender: TObject);
begin
  Try
    UpdateAccounts(false);
    UpdateBlockChainState;
  Except
    On E:Exception do begin
      E.Message := 'Error at OnNewAccount '+E.Message;
      Raise;
    end;
  end;
end;

procedure Tfrmpascwallet.OnNewLog(logtype: TLogType; Time : TDateTime; ThreadID : Cardinal; const sender,logtext: AnsiString);
Var s : AnsiString;
begin
  if (logtype=ltdebug) And (Not cbShowDebugLogs.Checked) then exit;
  if ThreadID=MainThreadID then s := ' MAIN:' else s:=' TID:';
  if MemoLogs.Lines.Count>300 then begin
    // Limit max lines in logs...
    memoLogs.Lines.BeginUpdate;
    try
      while memoLogs.Lines.Count>250 do memoLogs.Lines.Delete(0);
    finally
      memoLogs.Lines.EndUpdate;
    end;
  end;
  memoLogs.Lines.Add(formatDateTime('dd/mm/yyyy hh:nn:ss.zzz',Time)+s+IntToHex(ThreadID,8)+' ['+CT_LogType[Logtype]+'] <'+sender+'> '+logtext);
  //
end;

procedure Tfrmpascwallet.OnReceivedHelloMessage(Sender: TObject);
Var nsarr : TNodeServerAddressArray;
  i : Integer;
  s : AnsiString;
begin
  //CheckMining;
  // Update node servers Peer Cache
  nsarr := TNetData.NetData.GetValidNodeServers(true,0);
  s := '';
  for i := low(nsarr) to High(nsarr) do begin
    if (s<>'') then s := s+';';
    s := s + nsarr[i].ip+':'+IntToStr( nsarr[i].port );
  end;
  FAppParams.ParamByName[CT_PARAM_PeerCache].SetAsString(s);
  TNode.Node.PeerCache := s;
end;

procedure Tfrmpascwallet.OnWalletChanged(Sender: TObject);
begin
  if FMustProcessWalletChanged then exit;
  FMustProcessWalletChanged := true;
  PostMessage(Self.Handle,CM_PC_WalletKeysChanged,0,0);
end;

procedure Tfrmpascwallet.PageControlChange(Sender: TObject);
begin
  MiDecodePayload.Enabled := false;
  if PageControl.ActivePage=tsMyAccounts then begin
    //FAccountsGrid.Node := FNode;
    MiDecodePayload.Enabled := true;
    FSelectedAccountsGrid.Node := FNode;
  end else begin
    //FAccountsGrid.Node := Nil;
    FSelectedAccountsGrid.Node := Nil;
  end;
end;

procedure Tfrmpascwallet.SaveAppParams;
Var ms : TMemoryStream;
  s : AnsiString;
begin
  ms := TMemoryStream.Create;
  Try
    FAccountsGrid.SaveToStream(ms);
    ms.Position := 0;
    setlength(s,ms.Size);
    ms.ReadBuffer(s[1],ms.Size);
    FAppParams.ParamByName[CT_PARAM_GridAccountsStream].SetAsString(s);
  Finally
    ms.Free;
  End;
end;

procedure Tfrmpascwallet.sbSelectedAccountsAddAllClick(Sender: TObject);
Var lsource,ltarget : TOrderedCardinalList;
  i : Integer;
begin
  lsource := FAccountsGrid.LockAccountsList;
  Try
    ltarget := FSelectedAccountsGrid.LockAccountsList;
    Try
      for i := 0 to lsource.Count-1 do begin
        if FWalletKeys.IndexOfAccountKey(FNode.Bank.SafeBox.Account(lsource.Get(i)).accountInfo.accountKey)<0 then raise Exception.Create(Format('You cannot operate with account %d because private key not found in your wallet',[lsource.Get(i)]));
        ltarget.Add(lsource.Get(i));
      end;
    Finally
      FSelectedAccountsGrid.UnlockAccountsList;
    End;
  Finally
    FAccountsGrid.UnlockAccountsList;
  End;
end;

procedure Tfrmpascwallet.sbSelectedAccountsAddClick(Sender: TObject);
Var l, selected : TOrderedCardinalList;
  an : Int64;
  i : Integer;
begin
  an := FAccountsGrid.AccountNumber(dgAccounts.Row);
  if (an<0) then raise Exception.Create('No account selected');
  if FWalletKeys.IndexOfAccountKey(FNode.Bank.SafeBox.Account(an).accountInfo.accountkey)<0 then
    raise Exception.Create(Format('You cannot add %s account because private key not found in your wallet.'#10+#10+'You''re not the owner!',
      [TAccountComp.AccountNumberToAccountTxtNumber(an)]));
  // Add
  l := FSelectedAccountsGrid.LockAccountsList;
  selected := TOrderedCardinalList.Create;
  Try
    FAccountsGrid.SelectedAccounts(selected);
    for i := 0 to selected.Count-1 do begin
      l.Add(selected.Get(i));
    end;
  Finally
    selected.Free;
    FSelectedAccountsGrid.UnlockAccountsList;
  End;
end;

procedure Tfrmpascwallet.sbSelectedAccountsDelAllClick(Sender: TObject);
Var l : TOrderedCardinalList;
begin
  l := FSelectedAccountsGrid.LockAccountsList;
  try
    l.Clear;
  finally
    FSelectedAccountsGrid.UnlockAccountsList;
  end;
end;

procedure Tfrmpascwallet.TimerUpdateStatusTimer(Sender: TObject);
begin
  Try
    UpdateConnectionStatus;
    UpdateBlockChainState;
    UpdateNodeStatus;
  Except
    On E:Exception do begin
      E.Message := 'Exception at TimerUpdate '+E.ClassName+': '+E.Message;
      TLog.NewLog(lterror,ClassName,E.Message);
    end;
  End;
end;

procedure Tfrmpascwallet.UpdateAccounts(RefreshData : Boolean);
Var accl : TOrderedCardinalList;
  l : TOrderedCardinalList;
  i,j,k : Integer;
  c  : Cardinal;
  applyfilter : Boolean;
  acc : TAccount;
begin
  If Not Assigned(FOrderedAccountsKeyList) Then exit;
  if Not RefreshData then begin
    dgAccounts.Invalidate;
    exit;
  end;
  applyfilter := false;
  FAccountsGrid.ShowAllAccounts := (Not cbExploreMyAccounts.Checked) And (not applyfilter);
  if Not FAccountsGrid.ShowAllAccounts then begin
    accl := FAccountsGrid.LockAccountsList;
    Try
      accl.Clear;
      if cbExploreMyAccounts.Checked then begin
        if cbMyPrivateKeys.ItemIndex<0 then exit;
        if cbMyPrivateKeys.ItemIndex=0 then begin
          // All keys in the wallet
          for i := 0 to FWalletKeys.Count - 1 do begin
            j := FOrderedAccountsKeyList.IndexOfAccountKey(FWalletKeys[i].AccountKey);
            if (j>=0) then begin
              l := FOrderedAccountsKeyList.AccountKeyList[j];
              for k := 0 to l.Count - 1 do begin
                if applyfilter then begin
                  acc := FNode.Bank.SafeBox.Account(l.Get(k));
                  if (acc.balance>=FMinAccountBalance) And (acc.balance<=FMaxAccountBalance) then accl.Add(acc.account);
                end else accl.Add(l.Get(k));
              end;
            end;
          end;
        end else begin
          i := PtrInt(cbMyPrivateKeys.Items.Objects[cbMyPrivateKeys.ItemIndex]);
          if (i>=0) And (i<FWalletKeys.Count) then begin
            j := FOrderedAccountsKeyList.IndexOfAccountKey(FWalletKeys[i].AccountKey);
            if (j>=0) then begin
              l := FOrderedAccountsKeyList.AccountKeyList[j];
              for k := 0 to l.Count - 1 do begin
                if applyfilter then begin
                  acc := FNode.Bank.SafeBox.Account(l.Get(k));
                  if (acc.balance>=FMinAccountBalance) And (acc.balance<=FMaxAccountBalance) then accl.Add(acc.account);
                end else accl.Add(l.Get(k));
              end;
            end;
          end;
        end;
      end else begin
        // There is a filter... check every account...
        c := 0;
        while (c<FNode.Bank.SafeBox.AccountsCount) do begin
          acc := FNode.Bank.SafeBox.Account(c);
          if (acc.balance>=FMinAccountBalance) And (acc.balance<=FMaxAccountBalance) then accl.Add(acc.account);
          inc(c);
        end;
      end;
    Finally
      FAccountsGrid.UnlockAccountsList;
    End;
    lblAccountsCount.Caption := inttostr(accl.Count);
  end else begin
    lblAccountsCount.Caption := inttostr(FNode.Bank.AccountsCount);
  end;
  bbChangeKeyName.Enabled := cbExploreMyAccounts.Checked;
  // Show Totals:
  lblAccountsBalance.Caption := TAccountComp.FormatMoney(FAccountsGrid.AccountsBalance);
  UpdateOperations;
end;

procedure Tfrmpascwallet.UpdateBlockChainState;
Var isMining : boolean;
  i,mc : Integer;
  s : String;
  mtl : TList;
  f, favg : real;
begin
  UpdateNodeStatus;
  mc := 0;
  if Assigned(FNode) then begin
    if FNode.Bank.BlocksCount>0 then begin
      lblCurrentBlock.Caption :=  Inttostr(FNode.Bank.BlocksCount);
    end else lblCurrentBlock.Caption :=  '(none)';
    lblCurrentBlockTime.Caption := UnixTimeToLocalElapsedTime(FNode.Bank.LastOperationBlock.timestamp);
    favg := FNode.Bank.GetActualTargetSecondsAverage(CT_CalcNewTargetBlocksAverage);
    f := (CT_NewLineSecondsAvg - favg) / CT_NewLineSecondsAvg;
  end;
end;

procedure Tfrmpascwallet.UpdateConfigChanged;
Var wa : Boolean;
  i : Integer;
begin
  tsLogs.TabVisible := FAppParams.ParamByName[CT_PARAM_ShowLogs].GetAsBoolean(false);
  if (Not tsLogs.TabVisible) then begin
    FLog.OnNewLog := Nil;
    if PageControl.ActivePage = tsLogs then PageControl.ActivePage := tsMyAccounts;
  end else FLog.OnNewLog := OnNewLog;
  if FAppParams.ParamByName[CT_PARAM_SaveLogFiles].GetAsBoolean(false) then begin
    if FAppParams.ParamByName[CT_PARAM_SaveDebugLogs].GetAsBoolean(false) then FLog.SaveTypes := CT_TLogTypes_ALL
    else FLog.SaveTypes := CT_TLogTypes_DEFAULT;
    FLog.FileName := TFolderHelper.GetPascalCoinDataFolder+PathDelim+'PascalCointWallet.log';
  end else begin
    FLog.SaveTypes := [];
    FLog.FileName := '';
  end;
  if Assigned(FNode) then begin
    wa := FNode.NetServer.Active;
    FNode.NetServer.Port := FAppParams.ParamByName[CT_PARAM_InternetServerPort].GetAsInteger(CT_NetServer_Port);
    FNode.NetServer.Active := wa;
    FNode.Operations.BlockPayload := FAppParams.ParamByName[CT_PARAM_MinerName].GetAsString('');
    FNode.NodeLogFilename := TFolderHelper.GetPascalCoinDataFolder+PathDelim+'blocks.log';
  end;
  if Assigned(FPoolMiningServer) then begin
    if FPoolMiningServer.Port<>FAppParams.ParamByName[CT_PARAM_JSONRPCMinerServerPort].GetAsInteger(CT_JSONRPCMinerServer_Port) then begin
      FPoolMiningServer.Active := false;
      FPoolMiningServer.Port := FAppParams.ParamByName[CT_PARAM_JSONRPCMinerServerPort].GetAsInteger(CT_JSONRPCMinerServer_Port);
    end;
    FPoolMiningServer.Active :=FAppParams.ParamByName[CT_PARAM_JSONRPCMinerServerActive].GetAsBoolean(true);
    FPoolMiningServer.UpdateAccountAndPayload(GetAccountKeyForMiner,FAppParams.ParamByName[CT_PARAM_MinerName].GetAsString(''));
  end;
  if Assigned(FRPCServer) then begin
    FRPCServer.Active := FAppParams.ParamByName[CT_PARAM_JSONRPCEnabled].GetAsBoolean(false);
    FRPCServer.ValidIPs := FAppParams.ParamByName[CT_PARAM_JSONRPCAllowedIPs].GetAsString('127.0.0.1');
  end;
  i := FAppParams.ParamByName[CT_PARAM_MinerPrivateKeyType].GetAsInteger(Integer(mpk_Random));
  if (i>=Integer(Low(TMinerPrivatekey))) And (i<=Integer(High(TMinerPrivatekey))) then FMinerPrivateKeyType := TMinerPrivateKey(i)
  else FMinerPrivateKeyType := mpk_Random;
end;

procedure Tfrmpascwallet.UpdateConnectionStatus;
var errors : AnsiString;
begin
  UpdateNodeStatus;
  OnNetStatisticsChanged(Nil);
  if Assigned(FNode) then begin
    if FNode.IsBlockChainValid(errors) then begin
      StatusBar.Panels[2].Text := Format('Last account time:%s',
       [FormatDateTime('dd/mm/yyyy hh:nn:ss',UnivDateTime2LocalDateTime(UnixToUnivDateTime( FNode.Bank.LastOperationBlock.timestamp )))]);
    end else begin
      StatusBar.Panels[2].Text := 'NO BLOCKCHAIN: '+errors;
    end;
  end else begin
    StatusBar.Panels[2].Text := '';
  end;
end;

procedure Tfrmpascwallet.UpdateNodeStatus;
Var status : AnsiString;
begin
  If Not Assigned(FNode) then begin
    lblNodeStatus.Font.Color := clRed;
    lblNodeStatus.Caption := 'Initializing...';
  end else begin
    If FNode.IsReady(status) then begin
      if TNetData.NetData.NetStatistics.ActiveConnections>0 then begin
        lblNodeStatus.Font.Color := clGreen;
        if TNetData.NetData.IsDiscoveringServers then begin
          lblNodeStatus.Caption := 'Discovering servers';
        end else if TNetData.NetData.IsGettingNewBlockChainFromClient then begin
          lblNodeStatus.Caption := 'Obtaining new blockchain';
        end else begin
          lblNodeStatus.Caption := 'Running';
        end;
      end else begin
        lblNodeStatus.Font.Color := clRed;
        lblNodeStatus.Caption := 'Alone in the world...';
      end;
    end else begin
      lblNodeStatus.Font.Color := clRed;
      lblNodeStatus.Caption := status;
    end;
  end;
  If Assigned(FBackgroundPanel) then begin
    FBackgroundPanel.Font.Color:=lblNodeStatus.Font.Color;
    FBackgroundPanel.Caption:='Please wait until finished: '+lblNodeStatus.Caption;
  end;
end;

procedure Tfrmpascwallet.UpdateOperations;
Var accn : Int64;
begin
  accn := FAccountsGrid.AccountNumber(dgAccounts.Row);
  FOperationsAccountGrid.AccountNumber := accn;
  UpdatePayment(accn);
end;

procedure Tfrmpascwallet.UpdatePrivateKeys;
Var i,last_i : Integer;
  wk : TWalletKey;
  s : AnsiString;
begin
  If (Not Assigned(FOrderedAccountsKeyList)) And (Assigned(FNode)) Then begin
    FOrderedAccountsKeyList := TOrderedAccountKeysList.Create(FNode.Bank.SafeBox,false);
  end;
  if (cbMyPrivateKeys.ItemIndex>=0) then last_i := PtrInt(cbMyPrivateKeys.Items.Objects[cbMyPrivateKeys.ItemIndex])
  else last_i := -1;
  cbMyPrivateKeys.items.BeginUpdate;
  Try
    cbMyPrivateKeys.Items.Clear;
    For i:=0 to FWalletKeys.Count-1 do begin
      wk := FWalletKeys.Key[i];
      if assigned(FOrderedAccountsKeyList) then begin
        FOrderedAccountsKeyList.AddAccountKey(wk.AccountKey);
      end;
      if (wk.Name='') then begin
        s := 'Sha256='+TCrypto.ToHexaString( TCrypto.DoSha256( TAccountComp.AccountKey2RawString(wk.AccountKey) ) );
      end else begin
        s := wk.Name;
      end;
      if Not Assigned(wk.PrivateKey) then s := s + '(*)';
      cbMyPrivateKeys.Items.AddObject(s,TObject(i));
    end;
    cbMyPrivateKeys.Sorted := true;
    cbMyPrivateKeys.Sorted := false;
    cbMyPrivateKeys.Items.InsertObject(0,'(All my private keys)',TObject(-1));
  Finally
    cbMyPrivateKeys.Items.EndUpdate;
  End;
  last_i := cbMyPrivateKeys.Items.IndexOfObject(TObject(last_i));
  if last_i<0 then last_i := 0;
  if cbMyPrivateKeys.Items.Count>last_i then cbMyPrivateKeys.ItemIndex := last_i
  else if cbMyPrivateKeys.Items.Count>=0 then cbMyPrivateKeys.ItemIndex := 0;
end;

procedure Tfrmpascwallet.UpdatePayment(acc: int64);
var
  account : TAccount;
begin
//*
  edSendAcc.text := TAccountComp.AccountNumberToAccountTxtNumber(acc);
  if acc<0 then exit;
  account := FNode.Operations.SafeBoxTransaction.Account(acc);
  edSendBal.text := Format('%s',[TAccountComp.FormatMoney(account.balance)]);
end;

initialization
  frmpascwallet := Nil;
end.
