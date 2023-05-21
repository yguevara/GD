unit USecurityClasss;

interface

uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Data.DB, Data.Win.ADODB, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee,
  dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMetropolis, dxSkinMetropolisDark, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven,
  dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver,
  dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue, Vcl.Menus, cxLabel, cxDBLabel, Vcl.Grids, Vcl.DBGrids,
  Vcl.DBCtrls, Vcl.ComCtrls, JvExComCtrls, JvDateTimePicker, JvDBDateTimePicker,
  cxButtons, cxGroupBox, AdvOfficeStatusBar, Vcl.ExtCtrls, Vcl.ToolWin,
  System.StrUtils, cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator,
  cxDBData, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, cxDropDownEdit, cxDBLookupComboBox,
  cxDBNavigator, System.UITypes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.ExprFuncs,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Comp.UI,
  FireDAC.Phys.SQLite, cxDBEdit, Winapi.Windows;

type
  TSecurityClass = class
  private
    procedure DBComboBoxConfig(aff: TComponent; fat: Boolean; Acceso: string);
    procedure DBEditConfig(aff: TComponent; fat: Boolean; Acceso: string);
    procedure DBImageConfig(aff: TComponent; fat: Boolean; Acceso: string);
    procedure DBMemoConfig(aff: TComponent; fat: Boolean; Acceso: string);
    procedure DBGridConfig(aff: TComponent; fat: Boolean; Acceso: string);
    procedure DBDateTimePickerConfig(aff: TComponent; fat: Boolean; Acceso: string);
    procedure DBLookupComboBoxConfig(aff: TComponent; fat: Boolean; Acceso: string);
    procedure DBNavigatorConfig(aff: TComponent; Acceso: string);
    procedure cxDBMemoConfig(aff: TComponent; fat: Boolean; Acceso: string);
    procedure cxDBTextEditConfig(aff: TComponent; fat: Boolean; Acceso: string);
    procedure cxDBLookupComboBoxConfig(aff: TComponent; fat: Boolean; Acceso: string);
    procedure cxDBCheckBoxConfig(aff: TComponent; fat: Boolean; Acceso: string);
    procedure cxDBDateEditConfig(aff: TComponent; fat: Boolean; Acceso: string);
    procedure cxDBNavigatorConfig(fat: Boolean; aff: TComponent; Acceso: string);
    procedure cxGridDBTableViewConfig(fat: Boolean; aff: TComponent; Acceso: string);
    function sms(aText: string; aTipo: Integer): integer;
    { Private declarations }
  public
    { Public declarations }
    function GetRol(conn: TFDConnection; UserName, Pass, schname: string): string;
    function GetAccess(conn: TFDConnection; aIdRol, NombreMod: string): string;
    procedure SetModSecurity(aFrm: TForm; Acceso: string);
    procedure CreaMMenu(cadconn: widestring; aMM: TMainMenu; aIdRol, aUser: string);
    procedure ActNoAct(aff: TComponent; Acceso: string);
  end;

implementation

{ TSecurityClass }

uses
  md5;

procedure TSecurityClass.ActNoAct(aff: TComponent; Acceso: string);
var
  fat: Boolean;
begin
  //COMBOBOX
  fat := True;
  if aff is TDBComboBox then
  begin
    DBComboBoxConfig(aff, fat, Acceso);
  end;
  //DBEDIT
  if aff is TDBEdit then
  begin
    DBEditConfig(aff, fat, Acceso);
  end;
  //DBIMAGE
  if aff is TDBImage then
  begin
    DBImageConfig(aff, fat, Acceso);
  end;
  //DBMEMO
  if aff is TDBMemo then
  begin
    DBMemoConfig(aff, fat, Acceso);
  end;
  //DBGRID
  if aff is TDBGrid then
  begin
    DBGridConfig(aff, fat, Acceso);
  end;
  //DATETIMEPICKER
  if aff is TJvDBDateTimePicker then
  begin
    DBDateTimePickerConfig(aff, fat, Acceso);
  end;
  //LOOKUPCOMBOBOX
  if aff is TDBLookupComboBox then
  begin
    DBLookupComboBoxConfig(aff, fat, Acceso);
  end;
  //DBNAVIGATOR
  if aff is TDBNavigator then
    DBNavigatorConfig(aff, Acceso);
  if aff is TcxDBMemo then
    cxDBMemoConfig(aff, fat, Acceso);
  if aff is TcxDBTextEdit then
    cxDBTextEditConfig(aff, fat, Acceso);
  if aff is TcxDBLookupComboBox then
    cxDBLookupComboBoxConfig(aff, fat, Acceso);
  if aff is TcxDBCheckBox then
    cxDBCheckBoxConfig(aff, fat, Acceso);
  if aff is TcxDBDateEdit then
  begin
    cxDBDateEditConfig(aff, fat, Acceso);
  end;
  //NAVIGATOR DEVEXPRESS
  if aff is TcxDBNavigator then
  begin
    cxDBNavigatorConfig(fat, aff, Acceso);
  end;
  //GRID DEVEXPRESS
  if aff is TcxGridDBTableView then
  begin
    cxGridDBTableViewConfig(fat, aff, Acceso);
  end;
end;

procedure TSecurityClass.cxGridDBTableViewConfig(fat: Boolean; aff: TComponent; Acceso: string);
var
  i: Integer;
begin
  if AnsiLowerCase(Acceso) = 'acceso total' then
  begin
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Insert.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.First.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Prior.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Next.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Last.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Cancel.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Post.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Delete.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.PriorPage.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.NextPage.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Refresh.Visible := fat;
//    TcxGridDBTableView(aff as TcxGridDBTableView).NewItemRow.Visible := fat;
    if aff.Tag <> 1 then
    begin
      for i := 0 to TcxGridDBTableView(aff as TcxGridDBTableView).ColumnCount - 1 do
      begin
        TcxGridDBTableView(aff as TcxGridDBTableView).Columns[i].Options.Editing := fat;
        TcxGridDBTableView(aff as TcxGridDBTableView).Columns[i].Options.GroupFooters := fat;
        TcxGridDBTableView(aff as TcxGridDBTableView).Columns[i].Options.Grouping := fat;
        TcxGridDBTableView(aff as TcxGridDBTableView).Columns[i].Options.HorzSizing := fat;
        TcxGridDBTableView(aff as TcxGridDBTableView).Columns[i].Options.Moving := fat;
        TcxGridDBTableView(aff as TcxGridDBTableView).Columns[i].Options.ShowEditButtons := isebAlways;
      end;
    end;
  end
  else if AnsiLowerCase(Acceso) = 'solo lectura' then
  begin
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Insert.Visible := not fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.First.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Prior.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Next.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Last.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Cancel.Visible := not fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Post.Visible := not fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Delete.Visible := not fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.PriorPage.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.NextPage.Visible := fat;
    TcxGridDBTableView(aff as TcxGridDBTableView).Navigator.Buttons.Refresh.Visible := fat;
//    TcxGridDBTableView(aff as TcxGridDBTableView).NewItemRow.Visible := not fat;
    for i := 0 to TcxGridDBTableView(aff as TcxGridDBTableView).ColumnCount - 1 do
    begin
      TcxGridDBTableView(aff as TcxGridDBTableView).Columns[i].Options.Editing := not fat;
      TcxGridDBTableView(aff as TcxGridDBTableView).Columns[i].Options.GroupFooters := not fat;
      TcxGridDBTableView(aff as TcxGridDBTableView).Columns[i].Options.Grouping := not fat;
      TcxGridDBTableView(aff as TcxGridDBTableView).Columns[i].Options.HorzSizing := not fat;
      TcxGridDBTableView(aff as TcxGridDBTableView).Columns[i].Options.Moving := not fat;
      TcxGridDBTableView(aff as TcxGridDBTableView).Columns[i].Options.ShowEditButtons := isebNever;
    end;
  end;
end;

procedure TSecurityClass.cxDBNavigatorConfig(fat: Boolean; aff: TComponent; Acceso: string);
begin
  if AnsiLowerCase(Acceso) = 'acceso total' then
  begin
    if aff.Tag <> 1 then
    begin
      if aff.Tag <> 99 then
      begin
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.First.Visible := fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Prior.Visible := fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Next.Visible := fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Last.Visible := fat;
      //TcxDBNavigator(aff as TcxDBNavigator).Buttons.Append.Visible:=True;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Delete.Visible := fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Post.Visible := fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Cancel.Visible := fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Edit.Visible := fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Insert.Visible := fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Filter.Visible := fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.GotoBookmark.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.SaveBookmark.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.PriorPage.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.NextPage.Visible := not fat;
      end
      else
      begin
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.First.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Prior.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Next.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Last.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Append.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Insert.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Delete.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Post.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Cancel.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Edit.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Filter.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.Refresh.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.GotoBookmark.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.SaveBookmark.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.PriorPage.Visible := not fat;
        TcxDBNavigator(aff as TcxDBNavigator).Buttons.NextPage.Visible := not fat;
      end;
    end;
  end
  else if AnsiLowerCase(Acceso) = 'solo lectura' then
  begin
    if aff.Tag <> 99 then
    begin
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.First.Visible := fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Prior.Visible := fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Next.Visible := fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Last.Visible := fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Append.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Insert.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Delete.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Post.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Cancel.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Edit.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Filter.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Refresh.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.GotoBookmark.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.SaveBookmark.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.PriorPage.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.NextPage.Visible := not fat;
    end
    else
    begin
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.First.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Prior.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Next.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Last.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Append.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Insert.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Delete.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Post.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Cancel.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Edit.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Filter.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.Refresh.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.GotoBookmark.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.SaveBookmark.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.PriorPage.Visible := not fat;
      TcxDBNavigator(aff as TcxDBNavigator).Buttons.NextPage.Visible := not fat;
    end;
  end;
end;

procedure TSecurityClass.cxDBDateEditConfig(aff: TComponent; fat: Boolean; Acceso: string);
begin
  if AnsiLowerCase(Acceso) = 'acceso total' then
    TcxDBDateEdit(aff as TcxDBDateEdit).Properties.ReadOnly := not fat
  else if AnsiLowerCase(Acceso) = 'solo lectura' then
    TcxDBDateEdit(aff as TcxDBDateEdit).Properties.ReadOnly := fat;
end;

procedure TSecurityClass.cxDBCheckBoxConfig(aff: TComponent; fat: Boolean; Acceso: string);
begin
  if AnsiLowerCase(Acceso) = 'acceso total' then
    TcxDBCheckBox(aff as TcxDBCheckBox).Properties.ReadOnly := not fat
  else if AnsiLowerCase(Acceso) = 'solo lectura' then
    TcxDBCheckBox(aff as TcxDBCheckBox).Properties.ReadOnly := fat;
end;

procedure TSecurityClass.cxDBLookupComboBoxConfig(aff: TComponent; fat: Boolean; Acceso: string);
begin
  if TcxDBLookupComboBox(aff as TcxDBLookupComboBox).Tag <> 99 then
  begin
    if AnsiLowerCase(Acceso) = 'acceso total' then
      TcxDBLookupComboBox(aff as TcxDBLookupComboBox).Properties.ReadOnly := not fat
    else if AnsiLowerCase(Acceso) = 'solo lectura' then
      TcxDBLookupComboBox(aff as TcxDBLookupComboBox).Properties.ReadOnly := fat;
  end;
end;

procedure TSecurityClass.cxDBTextEditConfig(aff: TComponent; fat: Boolean; Acceso: string);
begin
  if TcxDBTextEdit(aff as TcxDBTextEdit).Tag <> 99 then
  begin
    if AnsiLowerCase(Acceso) = 'acceso total' then
      TcxDBTextEdit(aff as TcxDBTextEdit).Properties.ReadOnly := not fat
    else if AnsiLowerCase(Acceso) = 'solo lectura' then
      TcxDBTextEdit(aff as TcxDBTextEdit).Properties.ReadOnly := fat;
  end;
end;

procedure TSecurityClass.cxDBMemoConfig(aff: TComponent; fat: Boolean; Acceso: string);
begin
  if TcxDBMemo(aff as TcxDBMemo).Tag <> 99 then
  begin
    if AnsiLowerCase(Acceso) = 'acceso total' then
      TcxDBMemo(aff as TcxDBMemo).Properties.ReadOnly := not fat
    else if AnsiLowerCase(Acceso) = 'solo lectura' then
      TcxDBMemo(aff as TcxDBMemo).Properties.ReadOnly := fat;
  end;
end;

procedure TSecurityClass.DBNavigatorConfig(aff: TComponent; Acceso: string);
begin
  if AnsiLowerCase(Acceso) = 'acceso total' then
  begin
    if TDBNavigator(aff as TDBNavigator).Tag <> 99 then
      TDBNavigator(aff as TDBNavigator).VisibleButtons := [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel, nbRefresh]
  end
  else if AnsiLowerCase(Acceso) = 'solo lectura' then
    TDBNavigator(aff as TDBNavigator).VisibleButtons := [nbFirst, nbPrior, nbNext, nbLast, nbRefresh];
end;

procedure TSecurityClass.DBLookupComboBoxConfig(aff: TComponent; fat: Boolean; Acceso: string);
begin
  if AnsiLowerCase(Acceso) = 'acceso total' then
  begin
    TDBLookupComboBox(aff as TDBLookupComboBox).Enabled := fat;
    TDBLookupComboBox(aff as TDBLookupComboBox).ReadOnly := not fat;
    TDBLookupComboBox(aff as TDBLookupComboBox).Color := clWindow;
  end
  else if AnsiLowerCase(Acceso) = 'solo lectura' then
  begin
    TDBLookupComboBox(aff as TDBLookupComboBox).Enabled := not fat;
    TDBLookupComboBox(aff as TDBLookupComboBox).ReadOnly := fat;
    TDBLookupComboBox(aff as TDBLookupComboBox).Color := clBtnFace;
  end;
end;

procedure TSecurityClass.DBDateTimePickerConfig(aff: TComponent; fat: Boolean; Acceso: string);
begin
  if AnsiLowerCase(Acceso) = 'acceso total' then
  begin
    TJvDBDateTimePicker(aff as TJvDBDateTimePicker).Enabled := fat;
    TJvDBDateTimePicker(aff as TJvDBDateTimePicker).ReadOnly := not fat;
    TJvDBDateTimePicker(aff as TJvDBDateTimePicker).Color := clWindow;
  end
  else if AnsiLowerCase(Acceso) = 'solo lectura' then
  begin
    TJvDBDateTimePicker(aff as TJvDBDateTimePicker).Enabled := not fat;
    TJvDBDateTimePicker(aff as TJvDBDateTimePicker).ReadOnly := fat;
    TJvDBDateTimePicker(aff as TJvDBDateTimePicker).Color := clBtnFace;
  end;
end;

procedure TSecurityClass.DBGridConfig(aff: TComponent; fat: Boolean; Acceso: string);
begin
  if AnsiLowerCase(Acceso) = 'acceso total' then
  begin
    TDBGrid(aff as TDBGrid).Enabled := fat;
    //
    TDBGrid(aff as TDBGrid).Options := [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack];
    TDBGrid(aff as TDBGrid).ReadOnly := not fat;
  end
  else if AnsiLowerCase(Acceso) = 'solo lectura' then
  begin
    //TDBGrid(aff as TDBGrid).Enabled:=False;
    TDBGrid(aff as TDBGrid).Options := [dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack];
    TDBGrid(aff as TDBGrid).ReadOnly := fat;
  end;
end;

procedure TSecurityClass.DBMemoConfig(aff: TComponent; fat: Boolean; Acceso: string);
begin
  if AnsiLowerCase(Acceso) = 'acceso total' then
  begin
    TDBMemo(aff as TDBMemo).Enabled := fat;
    TDBMemo(aff as TDBMemo).ReadOnly := not fat;
    TDBMemo(aff as TDBMemo).Color := clWindow;
  end
  else if AnsiLowerCase(Acceso) = 'solo lectura' then
  begin
    TDBMemo(aff as TDBMemo).Enabled := not fat;
    TDBMemo(aff as TDBMemo).ReadOnly := fat;
    TDBMemo(aff as TDBMemo).Color := clBtnFace;
  end;
end;

procedure TSecurityClass.DBImageConfig(aff: TComponent; fat: Boolean; Acceso: string);
begin
  if AnsiLowerCase(Acceso) = 'acceso total' then
  begin
    TDBImage(aff as TDBImage).Enabled := fat;
    TDBImage(aff as TDBImage).ReadOnly := not fat;
    TDBImage(aff as TDBImage).Color := clWindow;
  end
  else if AnsiLowerCase(Acceso) = 'solo lectura' then
  begin
    TDBImage(aff as TDBImage).Enabled := not fat;
    TDBImage(aff as TDBImage).ReadOnly := fat;
    TDBImage(aff as TDBImage).Color := clBtnFace;
  end;
end;

procedure TSecurityClass.DBEditConfig(aff: TComponent; fat: Boolean; Acceso: string);
begin
  if AnsiLowerCase(Acceso) = 'acceso total' then
  begin
    TDBEdit(aff as TDBEdit).Enabled := fat;
    TDBEdit(aff as TDBEdit).ReadOnly := not fat;
    TDBEdit(aff as TDBEdit).Color := clWindow;
  end
  else if AnsiLowerCase(Acceso) = 'solo lectura' then
  begin
    TDBEdit(aff as TDBEdit).Enabled := not fat;
    TDBEdit(aff as TDBEdit).ReadOnly := fat;
    TDBEdit(aff as TDBEdit).Color := clBtnFace;
  end;
end;

procedure TSecurityClass.DBComboBoxConfig(aff: TComponent; fat: Boolean; Acceso: string);
begin
  if AnsiLowerCase(Acceso) = 'acceso total' then
  begin
    TDBComboBox(aff as TDBComboBox).Enabled := fat;
    TDBComboBox(aff as TDBComboBox).ReadOnly := not fat;
    TDBComboBox(aff as TDBComboBox).Color := clWindow;
  end
  else if AnsiLowerCase(Acceso) = 'solo lectura' then
  begin
    TDBComboBox(aff as TDBComboBox).Enabled := not fat;
    TDBComboBox(aff as TDBComboBox).ReadOnly := fat;
    TDBComboBox(aff as TDBComboBox).Color := clWindow;
  end;
end;

procedure TSecurityClass.CreaMMenu(cadconn: widestring; aMM: TMainMenu; aIdRol, aUser: string);
var
  i: integer;
  q, qq: TADOQuery;
  entro: boolean;

  procedure ActRec(Padre: TMenuItem; aq: TADOQuery);
  var
    j: Integer;
  begin
    for j := 0 to Padre.Count - 1 do
    begin
      if q.Locate('NombrePlugins', AnsiReplaceStr(Padre.Items[j].Caption, '&', ''), []) then
      begin
        if (q.FieldByName('NombreUser').AsString = aUser) or (q.FieldByName('NombreUser').AsString = '') then
        begin
          if ansilowercase(q.Fields[2].AsString) = 's' then
          begin
            if ansilowercase(q.Fields[1].AsString) <> 'sin acceso' then
            begin
              Padre.Items[j].Visible := True;
              Padre.Items[j].Enabled := True;
              entro := true;
              ActRec(Padre.Items[j], aq);
            end
            else
            begin
              Padre.Items[j].Visible := False;
              Padre.Items[j].Enabled := False;
            end;
          end
          else if ansilowercase(q.Fields[2].AsString) = 'n' then
          begin
            Padre.Items[j].Visible := False;
            Padre.Items[j].Enabled := False;
          end;
        end
        else
        begin
          Padre.Items[j].Visible := False;
          Padre.Items[j].Enabled := False;
        end;
      end
      else if Padre.Items[j].Tag = 0 then
      begin
        Padre.Items[j].Visible := True;
        Padre.Items[j].Enabled := True;
        entro := true;
        ActRec(Padre.Items[j], aq);
      end
      else
      begin
        Padre.Items[j].Visible := False;
        Padre.Items[j].Enabled := False;
      end;
    end;

  end;

begin
  q := TADOQuery.Create(nil);
  qq := TADOQuery.Create(nil);
  with qq do
  begin
    Active := False;
    ConnectionString := cadconn;
    SQL.Clear;
    SQL.Add('SELECT * FROM tb_tipoplugins');
    try
      Active := True;
    except
      on E: EDatabaseError do
      begin
        sms('No se pudo acceder al listado de módulos disponibles para el usuario actual. Motivo: ' + e.Message, 1);
        Exit;
      end;
    end;
  end;
  with q do
  try
    Active := False;
    ConnectionString := cadconn;
    SQL.Clear;
    SQL.Add('SELECT tb_plugins.NombrePlugins, tb_access.NombreAccess, tb_pluginsAccess.Habilitado, tb_pluginsAccess.NombreUser FROM tb_pluginsAccess ');
    SQL.Add(' INNER JOIN tb_plugins ON tb_pluginsAccess.IdPlugins = tb_plugins.IdPlugins INNER JOIN tb_access ON tb_pluginsAccess.IdAccess = tb_access.IdAccess');
    SQL.Add(' INNER JOIN Tb_Rol ON tb_pluginsAccess.IdRol = Tb_Rol.IdRol');
    SQL.Add(' WHERE Tb_Rol.Rol =' + chr(39) + aIdRol + Chr(39));       //+' AND tb_pluginsAccess.NombreUser ='+Chr(39)+aUser+Chr(39)
    try
      Active := True;
    except
      on E: EDatabaseError do
      begin
        sms('No se pudo acceder al listado de módulos disponibles para el usuario actual. Motivo: ' + e.Message, 1);
        Exit;
      end;
    end;
  finally
  end;
  if q.RecordCount <= 0 then
  begin
    for i := 0 to aMM.Items.Count - 1 do
    begin
      entro := False;
      if qq.Locate('Tipo', AnsiReplaceStr(aMM.Items[i].Caption, '&', ''), []) then
      begin
        aMM.Items[i].Visible := True;
        aMM.Items[i].Enabled := True;
        ActRec(aMM.Items[i], qq);
        if (not entro) and (ansilowercase(AnsiReplaceStr(aMM.Items[i].Caption, '&', '')) <> 'ayuda') then
        begin
          aMM.Items[i].Visible := False;
          aMM.Items[i].Enabled := False;
        end;
      end;
    end;
  end
  else
  begin
    for i := 0 to aMM.Items.Count - 1 do
    begin
      entro := False;
      if (qq.Locate('Tipo', AnsiReplaceStr(aMM.Items[i].Caption, '&', ''), [])) then
      begin
        aMM.Items[i].Visible := True;
        aMM.Items[i].Enabled := True;
        ActRec(aMM.Items[i], q);
        if (not entro) and (ansilowercase(AnsiReplaceStr(aMM.Items[i].Caption, '&', '')) <> 'ayuda') then
        begin
          aMM.Items[i].Visible := False;
          aMM.Items[i].Enabled := False;
        end;
      end;
    end;
  end;
  q.Free;
  qq.Free;
end;

function TSecurityClass.GetAccess(conn: TFDConnection; aIdRol, NombreMod: string): string;
begin
  Result := 'Sin Acceso';
  if trim(NombreMod) <> '' then
  begin
    with TFDQuery.Create(nil) do
    try
      Active := False;
      Connection := conn;
      SQL.Clear;
      SQL.Add('SELECT tb_pluginsAccess.NombreUser, tb_pluginsAccess.Habilitado, Tb_Rol.Rol, tb_access.NombreAccess FROM tb_pluginsAccess ');
      SQL.Add('INNER JOIN tb_plugins ON tb_pluginsAccess.IdPlugins = tb_plugins.IdPlugins INNER JOIN Tb_Rol ON tb_pluginsAccess.IdRol = Tb_Rol.IdRol ');
      SQL.Add(' INNER JOIN tb_access ON tb_pluginsAccess.IdAccess = tb_access.IdAccess WHERE tb_plugins.NombrePlugins =:pp');
      Params[0].Value := NombreMod;
      try
        Active := True;
        if Locate('Rol', aIdRol, []) then
        begin
          if (AnsiLowerCase(Fields[1].AsString) = 's') and (AnsiLowerCase(Fields[1].AsString) <> '') then
            Result := Fields[3].AsString
          else
            Result := 'Sin Acceso';
        end;
      except
        on E: EDatabaseError do
        begin
          sms('No se pudo obtener el grupo de usuarios al que pertenece el usuario especificado. Motivo: ' + e.Message, 1);
          Exit;
        end;
      end;

    finally
      Free;
    end;
  end
  else
  begin
    if (AnsiLowerCase(aIdRol) = 'administradores') or (AnsiLowerCase(aIdRol) = 'desarrolladores') or (AnsiLowerCase(aIdRol) = 'despachadores') then
      Result := 'Acceso Total'
    else
      Result := 'Solo Lectura';

  end;
end;

function TSecurityClass.GetRol(conn: TFDConnection; UserName, Pass, schname: string): string;
var
  CAD, CAD1: widestring;
begin
  Result := '';
  CAD1 := MD5Print(MD5String(Pass));
  CAD := 'SELECT tb_rol.rol FROM cl_Resp_Gest_Arch INNER JOIN tb_rol ON cl_Resp_Gest_Arch.rol = ';
  CAD := CAD + 'tb_rol.idrol WHERE cl_Resp_Gest_Arch.usuario =:pp AND cl_Resp_Gest_Arch.password =:aa';
  result := conn.ExecSQLScalar(CAD, [ansilowercase(UserName), CAD1]);
end;

procedure TSecurityClass.SetModSecurity(aFrm: TForm; Acceso: string);

  procedure AgregaItems(pepe: TComponent);
  var
    j: integer;
  begin
    for j := 0 to pepe.ComponentCount - 1 do
    begin
      ActNoAct(pepe.Components[j], Acceso);
      AgregaItems(pepe.Components[j]);
    end;
  end;

var
  i: Integer;
begin
  if AnsiLowerCase(Acceso) = 'sin acceso' then
  begin
    sms('No tiene acceso al módulo especificado. Por favor contacte con el administrador del sistema.', 1);
    Exit;
  end;
  for i := 0 to aFrm.ComponentCount - 1 do
  begin
    ActNoAct(aFrm.Components[i], Acceso);
    AgregaItems(aFrm.Components[i]);
  end;
end;

function TSecurityClass.sms(aText: string; aTipo: Integer): integer;
begin
  case aTipo of
    1:
      begin
        result:=Application.MessageBox(PChar(aText), PChar('¡Error!'), MB_OK + MB_ICONERROR + MB_DEFBUTTON1 + MB_APPLMODAL);
      end;
    2:
      begin
        result:=MessageBox(Application.Handle, PChar(aText), PChar('¡Alerta!'), MB_OK + MB_ICONEXCLAMATION + MB_DEFBUTTON1 + MB_APPLMODAL);
      end;
    3:
      begin
        result:=MessageBox(Application.Handle, PChar(aText), PChar('¡Información!'), MB_OK + MB_ICONINFORMATION + MB_DEFBUTTON1 + MB_APPLMODAL);
      end;
    4:
      begin
        result:=Application.MessageBox(PChar(aText), PChar('¡Confirmación!'), MB_YESNO+ MB_ICONQUESTION + MB_DEFBUTTON1 + MB_APPLMODAL);
      end;
  end;
end;

end.

