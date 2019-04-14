{ *******************************************************************************
Title: T2TiPDV
Description: Lista as Vendas.

The MIT License

Copyright: Copyright (C) 2015 T2Ti.COM

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

The author may be contacted at:
t2ti.com@gmail.com

@author Albert Eije
@version 1.0
******************************************************************************* }
unit UListaVendas;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, UBase,
  Dialogs, Grids, DBGrids, JvExDBGrids, JvDBGrid, StdCtrls, JvExStdCtrls,
  JvButton, JvCtrls, Buttons, JvExButtons, JvBitBtn, pngimage, ExtCtrls,
  JvEdit, JvValidateEdit, JvDBSearchEdit, DB, Provider, DBClient, FMTBcd,
  SqlExpr, JvEnterTab, JvComponentBase, Tipos, JvDBUltimGrid, Biblioteca, Controller,
  Vcl.Imaging.jpeg, LabeledCtrls;

type
  TCustomDBGridCracker = class(TCustomDBGrid);

  TFListaVendas = class(TFBase)
    Image1: TImage;
    botaoConfirma: TJvBitBtn;
    botaoCancela: TJvImgBtn;
    Panel1: TPanel;
    Label1: TLabel;
    EditLocaliza: TEdit;
    SpeedButton1: TSpeedButton;
    DSNFCe: TDataSource;
    Label2: TLabel;
    JvEnterAsTab1: TJvEnterAsTab;
    CDSNFCe: TClientDataSet;
    GridPrincipal: TJvDBUltimGrid;
    Image2: TImage;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Localiza;
    procedure Confirma;
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure GridPrincipalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure botaoConfirmaClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GridPrincipalDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: integer; Column: TColumn; State: TGridDrawState);
    procedure EditLocalizaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  private
    { Private declarations }
  public
    Operacao: String;
    Confirmou: Boolean;
    { Public declarations }
  end;

var
  FListaVendas: TFListaVendas;

implementation

uses
  NFeCabecalhoVO, VendaController,
  UCaixa;

{$R *.dfm}

{$REGION 'Infra'}
procedure TFListaVendas.FormActivate(Sender: TObject);
begin
  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);

  Confirmou := False;

  // Configura a Grid
  ConfiguraCDSFromVO(CDSNFCe, TNFeCabecalhoVO);
  ConfiguraGridFromVO(GridPrincipal, TNFeCabecalhoVO);

  CDSNFCe.Open;
end;

procedure TFListaVendas.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FCaixa.editCodigo.SetFocus;
  Action := caFree;
end;

procedure TFListaVendas.EditLocalizaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) or (Key = VK_UP) or (Key = VK_DOWN) then
    GridPrincipal.SetFocus;
end;

procedure TFListaVendas.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F2 then
    Localiza;
  if Key = VK_F12 then
    Confirma;
end;

procedure TFListaVendas.GridPrincipalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    EditLocaliza.SetFocus;
end;
{$ENDREGION 'Infra'}

{$REGION 'Pesquisa e Confirma��o'}
procedure TFListaVendas.SpeedButton1Click(Sender: TObject);
begin
  Localiza;
end;

procedure TFListaVendas.botaoConfirmaClick(Sender: TObject);
begin
  if GridPrincipal.DataSource.DataSet.Active then
  begin
    if GridPrincipal.DataSource.DataSet.RecordCount > 0 then
      Confirma
    else
    begin
      Application.MessageBox('N�o existem registros selecionados.', 'Informa��o do Sistema', MB_OK + MB_ICONINFORMATION);
      EditLocaliza.SetFocus;
    end;
  end
  else
  begin
    Application.MessageBox('N�o existem registros selecionados.', 'Informa��o do Sistema', MB_OK + MB_ICONINFORMATION);
    EditLocaliza.SetFocus;
  end;
end;

procedure TFListaVendas.Confirma;
begin
  Confirmou := True;
  Close;
end;

procedure TFListaVendas.GridPrincipalDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: integer; Column: TColumn; State: TGridDrawState);
begin
  with TCustomDBGridCracker(Sender) do
  begin
    if DataLink.ActiveRecord = Row - 1 then
    begin
      Canvas.Brush.Color := clInfoBk;
      Canvas.Font.Style := [fsBold];
      Canvas.Font.Color := clBlack;
      Canvas.Font.Name := 'Verdana';
      Canvas.Font.Size := 8;
    end
    else
      Canvas.Font.Color := clBlack;
    DefaultDrawColumnCell(Rect, DataCol, Column, State);
  end;
end;

procedure TFListaVendas.Localiza;
var
  ProcurePor, Filtro: String;
begin
  ProcurePor := '%' + EditLocaliza.Text + '%';
  Filtro := 'STATUS_NOTA < 4 AND NUMERO LIKE '+ QuotedStr(ProcurePor);
  TVendaController.SetDataSet(CDSNFCe);
  TController.ExecutarMetodo('VendaController.TVendaController', 'Consulta', [Filtro, '0', False], 'GET', 'Lista');
end;
{$ENDREGION 'Pesquisa e Confirma��o'}

end.
