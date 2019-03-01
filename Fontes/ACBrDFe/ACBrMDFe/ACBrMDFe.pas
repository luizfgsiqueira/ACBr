{******************************************************************************}
{ Projeto: Componente ACBrMDFe                                                 }
{  Biblioteca multiplataforma de componentes Delphi                            }
{                                                                              }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do Projeto ACBr     }
{ Componentes localizado em http://www.sourceforge.net/projects/acbr           }
{                                                                              }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Sim�es de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br  }
{              Pra�a Anita Costa, 34 - Tatu� - SP - 18270-410                  }
{                                                                              }
{******************************************************************************}

{*******************************************************************************
|* Historico
|*
|* 01/08/2012: Italo Jurisato Junior
|*  - Doa��o do componente para o Projeto ACBr
*******************************************************************************}

{$I ACBr.inc}

unit ACBrMDFe;

interface

uses
  Classes, SysUtils,
  ACBrDFe, ACBrDFeConfiguracoes,
  ACBrMDFeConfiguracoes, ACBrMDFeWebServices, ACBrMDFeManifestos,
  ACBrMDFeDAMDFEClass,ACBrDFeException,
  pmdfeMDFe, pcnConversao, pmdfeConversaoMDFe,
  pmdfeEnvEventoMDFe, 
  ACBrUtil;

const
  ACBRMDFE_NAMESPACE = 'http://www.portalfiscal.inf.br/mdfe';
  ACBRMDFE_CErroAmbDiferente = 'Ambiente do XML (tpAmb) � diferente do '+
     'configurado no Componente (Configuracoes.WebServices.Ambiente)';

type
  EACBrMDFeException = class(EACBrDFeException);
	{$IFDEF RTL230_UP}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  {$ENDIF RTL230_UP}	
  TACBrMDFe = class(TACBrDFe)
  private
    FDAMDFE: TACBrMDFeDAMDFEClass;
    FManifestos: TManifestos;
    FEventoMDFe: TEventoMDFe;
    FStatus: TStatusACBrMDFe;
    FWebServices: TWebServices;

    function GetConfiguracoes: TConfiguracoesMDFe;
    function Distribuicao(const ACNPJCPF, AultNSU, ANSU,
      AchMDFe: String): Boolean;

    procedure SetConfiguracoes(AValue: TConfiguracoesMDFe);
    procedure SetDAMDFE(const Value: TACBrMDFeDAMDFEClass);
  protected
    function CreateConfiguracoes: TConfiguracoes; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    function NomeServicoToNomeSchema(const NomeServico: String): String; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure EnviarEmail(const sPara, sAssunto: String;
      sMensagem: TStrings = nil; sCC: TStrings = nil; Anexos: TStrings = nil;
      StreamMDFe: TStream = nil; const NomeArq: String = ''; sReplyTo: TStrings = nil); override;

    function Enviar(ALote: integer; Imprimir: Boolean = True): Boolean; overload;
    function Enviar(const ALote: String; Imprimir: Boolean = True): Boolean; overload;

    function GetNomeModeloDFe: String; override;
    function GetNameSpaceURI: String; override;

    function cStatConfirmado(AValue: integer): Boolean;
    function cStatProcessado(AValue: integer): Boolean;
    function cStatCancelado(AValue: integer): Boolean;

    function Consultar( const AChave: String = ''): Boolean;
    function ConsultarMDFeNaoEnc(const ACNPJCPF: String): Boolean;
    function Cancelamento(const AJustificativa: String; ALote: integer = 0): Boolean;
    function EnviarEvento(idLote: integer): Boolean;

    procedure LerServicoDeParams(LayOutServico: TLayOutMDFe; var Versao: Double;
      var URL: String); reintroduce; overload;
    function LerVersaoDeParams(LayOutServico: TLayOutMDFe): String; reintroduce; overload;

    function IdentificaSchema(const AXML: String): TSchemaMDFe;
    function IdentificaSchemaModal(const AXML: String): TSchemaMDFe;
    function IdentificaSchemaEvento(const AXML: String): TSchemaMDFe;

    function GerarNomeArqSchema(const ALayOut: TLayOutMDFe; VersaoServico: Double): String;
    function GerarNomeArqSchemaModal(const AXML: String; VersaoServico: Double): String;
    function GerarNomeArqSchemaEvento(ASchemaEventoMDFe: TSchemaMDFe; VersaoServico: Double): String;

    function GerarChaveContingencia(FMDFe: TMDFe): String;

    property WebServices: TWebServices read FWebServices write FWebServices;
    property Manifestos: TManifestos read FManifestos write FManifestos;
    property EventoMDFe: TEventoMDFe read FEventoMDFe write FEventoMDFe;
    property Status: TStatusACBrMDFe read FStatus;

    procedure SetStatus(const stNewStatus: TStatusACBrMDFe);
    procedure ImprimirEvento;
    procedure ImprimirEventoPDF;
    function DistribuicaoDFePorUltNSU(const ACNPJCPF, AultNSU: String): Boolean;
    function DistribuicaoDFePorNSU(const ACNPJCPF, ANSU: String): Boolean;
    function DistribuicaoDFePorChaveMDFe(const ACNPJCPF, AchMDFe: String): Boolean;

  published
    property Configuracoes: TConfiguracoesMDFe
      read GetConfiguracoes write SetConfiguracoes;
    property DAMDFE: TACBrMDFeDAMDFEClass read FDAMDFE write SetDAMDFE;
  end;

implementation

uses
  strutils, dateutils,
  pcnAuxiliar, synacode;

{$IFDEF FPC}
 {$IFDEF CPU64}
  {$R ACBrMDFeServicos.res}  // Dificuldades de compilar Recurso em 64 bits
 {$ELSE}
  {$R ACBrMDFeServicos.rc}
 {$ENDIF}
{$ELSE}
 {$R ACBrMDFeServicos.res}
{$ENDIF}

{ TACBrMDFe }

constructor TACBrMDFe.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FManifestos := TManifestos.Create(Self, Manifesto);
  FEventoMDFe := TEventoMDFe.Create;
  FWebServices := TWebServices.Create(Self);
end;

destructor TACBrMDFe.Destroy;
begin
  FManifestos.Free;
  FEventoMDFe.Free;
  FWebServices.Free;

  inherited;
end;

procedure TACBrMDFe.EnviarEmail(const sPara, sAssunto: String; sMensagem: TStrings;
  sCC: TStrings; Anexos: TStrings; StreamMDFe: TStream; const NomeArq: String;
  sReplyTo: TStrings);
begin
  SetStatus( stMDFeEmail );

  try
    inherited EnviarEmail(sPara, sAssunto, sMensagem, sCC, Anexos, StreamMDFe, NomeArq,
      sReplyTo);
  finally
    SetStatus( stMDFeIdle );
  end;
end;

procedure TACBrMDFe.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and (FDAMDFe <> nil) and
     (AComponent is TACBrMDFeDAMDFeClass) then
    FDAMDFe := nil;
end;

function TACBrMDFe.CreateConfiguracoes: TConfiguracoes;
begin
  Result := TConfiguracoesMDFe.Create(Self);
end;

procedure TACBrMDFe.SetDAMDFe(const Value: TACBrMDFeDAMDFeClass);
var
 OldValue: TACBrMDFeDAMDFeClass;
begin
  if Value <> FDAMDFe then
  begin
    if Assigned(FDAMDFe) then
      FDAMDFe.RemoveFreeNotification(Self);

    OldValue := FDAMDFe;   // Usa outra variavel para evitar Loop Infinito
    FDAMDFe  := Value;    // na remo��o da associa��o dos componentes

    if Assigned(OldValue) then
      if Assigned(OldValue.ACBrMDFe) then
        OldValue.ACBrMDFe := nil;

    if Value <> nil then
     begin
       Value.FreeNotification(self);
       Value.ACBrMDFe := self;
     end;
  end;
end;

function TACBrMDFe.GetNomeModeloDFe: String;
begin
  Result := 'MDFe';
end;

function TACBrMDFe.GetNameSpaceURI: String;
begin
  Result := ACBRMDFE_NAMESPACE;
end;

function TACBrMDFe.cStatConfirmado(AValue: integer): Boolean;
begin
  case AValue of
    100, 150: Result := True;
    else
      Result := False;
  end;
end;

function TACBrMDFe.cStatProcessado(AValue: integer): Boolean;
begin
  case AValue of
    100, 110, 150, 301, 302: Result := True;
    else
      Result := False;
  end;
end;

function TACBrMDFe.cStatCancelado(AValue: integer): Boolean;
begin
  case AValue of
    101, 151, 155: Result := True;
    else
      Result := False;
  end;
end;

function TACBrMDFe.IdentificaSchema(const AXML: String): TSchemaMDFe;
var
 lTipoEvento: TpcnTpEvento;
 I: Integer;
 Ok: Boolean;
begin
  Result := schMDFe;

  I := pos('<infMDFe', AXML);
  if I = 0 then
  begin
    I := pos('<infEvento', AXML);
    if I > 0 then
    begin
      lTipoEvento := StrToTpEvento(Ok, Trim(RetornarConteudoEntre(AXML, '<tpEvento>', '</tpEvento>')));

      case lTipoEvento of
        teCancelamento: Result := schevCancMDFe;
        teEncerramento: Result := schevEncMDFe;
        else Result := schevIncCondutorMDFe;
      end;
    end;
  end;
end;

function TACBrMDFe.IdentificaSchemaModal(const AXML: String): TSchemaMDFe;
var
  XML: String;
  I: Integer;
begin
  XML := Trim(RetornarConteudoEntre(AXML, '<infModal', '</infModal>'));

  Result := schmdfeModalRodoviario;

  I := pos( '<rodo>', XML);
  if I = 0 then
  begin
    I := pos( '<aereo>', XML);
    if I> 0 then
      Result := schmdfeModalAereo
    else begin
      I := pos( '<aquav>', XML);
      if I> 0 then
        Result := schmdfeModalAquaviario
      else begin
        I := pos( '<ferrov>', XML);
        if I> 0 then
          Result := schmdfeModalFerroviario
        else
          Result := schErro;
      end;
    end;
  end;
end;

function TACBrMDFe.IdentificaSchemaEvento(const AXML: String): TSchemaMDFe;
begin
  // Implementar
  Result := schErro;
end;

function TACBrMDFe.GerarNomeArqSchema(const ALayOut: TLayOutMDFe;
  VersaoServico: Double): String;
var
  NomeServico, NomeSchema, ArqSchema: String;
  Versao: Double;
begin
  // Procura por Vers�o na pasta de Schemas //
  NomeServico := LayOutToServico(ALayOut);
  NomeSchema := NomeServicoToNomeSchema(NomeServico);
  ArqSchema := '';
  if NaoEstaVazio(NomeSchema) then
  begin
    Versao := VersaoServico;
    AchaArquivoSchema( NomeSchema, Versao, ArqSchema );
  end;

  Result := ArqSchema;
end;

function TACBrMDFe.GerarNomeArqSchemaModal(const AXML: String;
  VersaoServico: Double): String;
begin
  if VersaoServico = 0.0 then
    Result := ''
  else
    Result := PathWithDelim( Configuracoes.Arquivos.PathSchemas ) +
              SchemaMDFeToStr(IdentificaSchemaModal(AXML)) + '_v' +
              FloatToString(VersaoServico, '.', '0.00') + '.xsd';
end;

function TACBrMDFe.GerarNomeArqSchemaEvento(ASchemaEventoMDFe: TSchemaMDFe;
  VersaoServico: Double): String;
begin
  if VersaoServico = 0.0 then
    Result := ''
  else
    Result := PathWithDelim( Configuracoes.Arquivos.PathSchemas ) +
              SchemaMDFeToStr(ASchemaEventoMDFe) + '_v' +
              FloatToString(VersaoServico, '.', '0.00') + '.xsd';
end;

function TACBrMDFe.GerarChaveContingencia(FMDFe: TMDFe): String;

  function GerarDigito_Contigencia(out Digito: integer; chave: String): Boolean;
  var
    i, j: integer;
  const
    PESO = '43298765432987654329876543298765432';
  begin
    chave := OnlyNumber(chave);
    j := 0;
    Digito := 0;
    Result := True;
    try
      for i := 1 to 35 do
        j := j + StrToInt(copy(chave, i, 1)) * StrToInt(copy(PESO, i, 1));
      Digito := 11 - (j mod 11);
      if (j mod 11) < 2 then
        Digito := 0;
    except
      Result := False;
    end;
    if length(chave) <> 35 then
      Result := False;
  end;

var
  wchave: String;
//  Digito: integer;
begin
  wchave := '';

  Result := wchave;
end;

function TACBrMDFe.GetConfiguracoes: TConfiguracoesMDFe;
begin
  Result := TConfiguracoesMDFe(FPConfiguracoes);
end;

procedure TACBrMDFe.SetConfiguracoes(AValue: TConfiguracoesMDFe);
begin
  FPConfiguracoes := AValue;
end;

function TACBrMDFe.LerVersaoDeParams(LayOutServico: TLayOutMDFe): String;
var
  Versao: Double;
begin
  Versao := LerVersaoDeParams(GetNomeModeloDFe, Configuracoes.WebServices.UF,
    Configuracoes.WebServices.Ambiente, LayOutToServico(LayOutServico),
    VersaoMDFeToDbl(Configuracoes.Geral.VersaoDF));

  Result := FloatToString(Versao, '.', '0.00');
end;

function TACBrMDFe.NomeServicoToNomeSchema(const NomeServico: String): String;
Var
  ok: Boolean;
  ALayout: TLayOutMDFe;
begin
  ALayout := ServicoToLayOut(ok, NomeServico);
  if ok then
    Result := SchemaMDFeToStr( LayOutToSchema( ALayout ) )
  else
    Result := '';
end;

procedure TACBrMDFe.LerServicoDeParams(LayOutServico: TLayOutMDFe;
  var Versao: Double; var URL: String);
begin
  Versao := VersaoMDFeToDbl(Configuracoes.Geral.VersaoDF);
  URL := '';
  LerServicoDeParams(GetNomeModeloDFe, Configuracoes.WebServices.UF,
    Configuracoes.WebServices.Ambiente, LayOutToServico(LayOutServico),
    Versao, URL);
end;

procedure TACBrMDFe.SetStatus(const stNewStatus: TStatusACBrMDFe);
begin
  if stNewStatus <> FStatus then
  begin
    FStatus := stNewStatus;
    if Assigned(OnStatusChange) then
      OnStatusChange(Self);
  end;
end;

function TACBrMDFe.Cancelamento(const AJustificativa: String; ALote: integer = 0): Boolean;
var
  i: integer;
begin
  if Manifestos.Count = 0 then
    GerarException(ACBrStr('ERRO: Nenhum MDF-e Informado!'));

  for i := 0 to Manifestos.Count - 1 do
  begin
    WebServices.Consulta.MDFeChave := Manifestos.Items[i].NumID;

    if not WebServices.Consulta.Executar then
      raise Exception.Create(WebServices.Consulta.Msg);

    EventoMDFe.Evento.Clear;
    with EventoMDFe.Evento.New do
    begin
      infEvento.CNPJCPF  := copy(OnlyNumber(WebServices.Consulta.MDFeChave), 7, 14);
      infEvento.cOrgao   := StrToIntDef(copy(OnlyNumber(WebServices.Consulta.MDFeChave), 1, 2), 0);
      infEvento.dhEvento := now;
      infEvento.tpEvento := teCancelamento;
      infEvento.chMDFe   := WebServices.Consulta.MDFeChave;

      infEvento.detEvento.nProt := WebServices.Consulta.Protocolo;
      infEvento.detEvento.xJust := AJustificativa;
    end;

    try
      EnviarEvento(ALote);
    except
      raise Exception.Create(WebServices.EnvEvento.EventoRetorno.xMotivo);
    end;
  end;
  Result := True;
end;

function TACBrMDFe.Consultar(const AChave: String): Boolean;
var
 i: Integer;
begin
  if (Manifestos.Count = 0) and EstaVazio(AChave) then
    GerarException(ACBrStr('ERRO: Nenhum MDF-e ou Chave Informada!'));

  if NaoEstaVazio(AChave) then
  begin
    Manifestos.Clear;
    WebServices.Consulta.MDFeChave := AChave;
    WebServices.Consulta.Executar;
  end
  else
  begin
    for i := 0 to Manifestos.Count - 1 do
    begin
      WebServices.Consulta.MDFeChave := Manifestos.Items[i].NumID;
      WebServices.Consulta.Executar;
    end;
  end;

  Result := True;
end;

function TACBrMDFe.ConsultarMDFeNaoEnc(const ACNPJCPF: String): Boolean;
begin
  Result := WebServices.ConsultaMDFeNaoEnc(ACNPJCPF);
end;

function TACBrMDFe.Enviar(ALote: Integer; Imprimir:Boolean = True): Boolean;
begin
  Result := Enviar(IntToStr(ALote), Imprimir);
end;

function TACBrMDFe.Enviar(const ALote: String; Imprimir:Boolean = True): Boolean;
var
 i: Integer;
begin
  WebServices.Enviar.Clear;
  WebServices.Retorno.Clear;

  if Manifestos.Count <= 0 then
    GerarException(ACBrStr('ERRO: Nenhum MDF-e adicionado ao Lote'));

  if Manifestos.Count > 1 then
    GerarException(ACBrStr('ERRO: Conjunto de MDF-e transmitidos (m�ximo de 1 MDF-e)' +
      ' excedido. Quantidade atual: ' + IntToStr(Manifestos.Count)));

  Manifestos.Assinar;
  Manifestos.Validar;

  Result := WebServices.Envia(ALote);

  if DAMDFE <> nil then
  begin
    for i := 0 to Manifestos.Count - 1 do
    begin
      if Manifestos.Items[i].Confirmado and Imprimir then
      begin
        Manifestos.Items[i].Imprimir;
      end;
    end;
  end;
end;

function TACBrMDFe.EnviarEvento(idLote: Integer): Boolean;
var
  i, j: integer;
  chMDFe: String;
begin
  if EventoMDFe.Evento.Count <= 0 then
    GerarException(ACBrStr('ERRO: Nenhum Evento adicionado ao Lote'));

  if EventoMDFe.Evento.Count > 1 then
    GerarException(ACBrStr('ERRO: Conjunto de Eventos transmitidos (m�ximo de 1) ' +
      'excedido. Quantidade atual: ' + IntToStr(EventoMDFe.Evento.Count)));

  WebServices.EnvEvento.idLote := idLote;

  {Atribuir nSeqEvento, CNPJ, Chave e/ou Protocolo quando n�o especificar}
  for i := 0 to EventoMDFe.Evento.Count - 1 do
  begin
    if EventoMDFe.Evento.Items[i].InfEvento.nSeqEvento = 0 then
      EventoMDFe.Evento.Items[i].infEvento.nSeqEvento := 1;

    FEventoMDFe.Evento.Items[i].InfEvento.tpAmb := Configuracoes.WebServices.Ambiente;

    if Manifestos.Count > 0 then
    begin
      chMDFe := OnlyNumber(EventoMDFe.Evento.Items[i].InfEvento.chMDFe);

      // Se tem a chave do MDFe no Evento, procure por ela nos manifestos carregados //
      if NaoEstaVazio(chMDFe) then
      begin
        for j := 0 to Manifestos.Count - 1 do
        begin
          if chMDFe = Manifestos.Items[j].NumID then
            Break;
        end;

        if j = Manifestos.Count then
          GerarException( ACBrStr('N�o existe MDFe com a chave ['+chMDFe+'] carregado') );
      end
      else
        j := 0;

      if trim(EventoMDFe.Evento.Items[i].InfEvento.CNPJCPF) = '' then
        EventoMDFe.Evento.Items[i].InfEvento.CNPJCPF := Manifestos.Items[j].MDFe.Emit.CNPJCPF;

      if chMDFe = '' then
        EventoMDFe.Evento.Items[i].InfEvento.chMDFe := Manifestos.Items[j].NumID;

      if trim(EventoMDFe.Evento.Items[i].infEvento.detEvento.nProt) = '' then
      begin
        if EventoMDFe.Evento.Items[i].infEvento.tpEvento = teCancelamento then
        begin
          EventoMDFe.Evento.Items[i].infEvento.detEvento.nProt := Manifestos.Items[j].MDFe.procMDFe.nProt;

          if trim(EventoMDFe.Evento.Items[i].infEvento.detEvento.nProt) = '' then
          begin
            WebServices.Consulta.MDFeChave := EventoMDFe.Evento.Items[i].InfEvento.chMDFe;

            if not WebServices.Consulta.Executar then
              GerarException(WebServices.Consulta.Msg);

            EventoMDFe.Evento.Items[i].infEvento.detEvento.nProt := WebServices.Consulta.Protocolo;
          end;
        end;
      end;
    end;
  end;

  Result := WebServices.EnvEvento.Executar;

  if not Result then
    GerarException( WebServices.EnvEvento.Msg );
end;

procedure TACBrMDFe.ImprimirEvento;
begin
  if not Assigned(DAMDFE) then
     raise EACBrMDFeException.Create('Componente DAMDFE n�o associado.')
  else
     DAMDFE.ImprimirEVENTO(nil);
end;

procedure TACBrMDFe.ImprimirEventoPDF;
begin
  if not Assigned(DAMDFE) then
     raise EACBrMDFeException.Create('Componente DAMDFE n�o associado.')
  else
     DAMDFE.ImprimirEVENTOPDF(nil);
end;

function TACBrMDFe.Distribuicao(const ACNPJCPF, AultNSU, ANSU,
      AchMDFe: String): Boolean;
begin
  WebServices.DistribuicaoDFe.CNPJCPF := ACNPJCPF;
  WebServices.DistribuicaoDFe.ultNSU  := AultNSU;
  WebServices.DistribuicaoDFe.NSU     := ANSU;
  WebServices.DistribuicaoDFe.chMDFe  := AchMDFe;

  Result := WebServices.DistribuicaoDFe.Executar;

  if not Result then
    GerarException( WebServices.DistribuicaoDFe.Msg );
end;

function TACBrMDFe.DistribuicaoDFePorUltNSU(const ACNPJCPF, AultNSU: String): Boolean;
begin
  Result := Distribuicao(ACNPJCPF, AultNSU, '', '');
end;

function TACBrMDFe.DistribuicaoDFePorNSU(const ACNPJCPF, ANSU: String): Boolean;
begin
  Result := Distribuicao(ACNPJCPF, '', ANSU, '');
end;

function TACBrMDFe.DistribuicaoDFePorChaveMDFe(const ACNPJCPF,
  AchMDFe: String): Boolean;
begin
  // Aguardando a SEFAZ implementar esse recurso j� existente para a NF-e.
  Result := False;
  GerarException('Aguardando a SEFAZ implementar esse recurso j� existente para a NF-e.');

//  Result := Distribuicao(ACNPJCPF, '', '', AchMDFe);
end;

end.
