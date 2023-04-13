﻿unit Principal;

interface

uses
  {$IFDEF ANDROID}
    FMX.Platform.Android,
  {$ENDIF}
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.WebBrowser,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.Layouts, FMX.Objects,
  FMX.Ani, System.Sensors, System.Sensors.Components, UTM_WGS84, System.Math,
  Acerca, UtilMapas;

type
  TFPrinc = class(TForm)
    WebBrowser: TWebBrowser;
    ELat: TEdit;
    BBuscar: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LZoom: TLabel;
    TrBarZoom: TTrackBar;
    SBAcerca: TSpeedButton;
    LayPrinc: TLayout;
    ToolBar1: TToolBar;
    Label4: TLabel;
    LayMapa: TLayout;
    LayPanel: TLayout;
    SBSalir: TSpeedButton;
    LayLatitud: TLayout;
    LayLongitud: TLayout;
    LayZoom: TLayout;
    LayBuscar: TLayout;
    Rectangle1: TRectangle;
    LocSensor: TLocationSensor;
    SwGPS: TSwitch;
    Label5: TLabel;
    FloatAnimation1: TFloatAnimation;
    ELon: TEdit;
    ENorte: TEdit;
    EEste: TEdit;
    LayRumbo: TLayout;
    Label6: TLabel;
    LRumbo: TLabel;
    ImgFlecha: TImage;
    LayAcerca: TLayout;
    FrmAcerca1: TFrmAcerca;
    procedure FormShow(Sender: TObject);
    procedure BBuscarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TrBarZoomChange(Sender: TObject);
    procedure WebBrowserDidFinishLoad(ASender: TObject);
    procedure ELatKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure ELatChange(Sender: TObject);
    procedure SBAcercaClick(Sender: TObject);
    procedure SBSalirClick(Sender: TObject);
    procedure LocSensorLocationChanged(Sender: TObject; const OldLocation,
      NewLocation: TLocationCoord2D);
    procedure SwGPSSwitch(Sender: TObject);
    procedure LocSensorHeadingChanged(Sender: TObject;
      const AHeading: THeading);
    procedure FrmAcerca1BAceptarClick(Sender: TObject);
  private

  public
    { Public declarations }
  end;

const
  MapURL='https://www.openstreetmap.org/';

var
  FPrinc: TFPrinc;
  Ubication: TUbicacion;
  FActiveForm: TForm;

implementation

{$R *.fmx}
{$R *.BAE2E2665F7E41AE9F0947E9D8BC3706.fmx ANDROID}
{$R *.LgXhdpiPh.fmx ANDROID}

uses
  System.Permissions, FMX.DialogService;

procedure ParseURLToCoords(sURL: string; var Ubic: TUbicacion);
var
  I,Pos: integer;
begin
  Ubic.Zoom:='';
  Ubic.Lat:='';
  Ubic.Lon:='';
  Ubic.URLFull:=sURL;
  if sURL<>MapURL then
  begin
    //desgranar aquí partiendo de la cadena "#map="
    Pos:=Length(MapURL+'#map=')+1;
    for I:=1 to 2 do
    begin
      while Copy(sURL,Pos,1)<>'/' do
      begin
        if I=1 then Ubic.Zoom:=Ubic.Zoom+Copy(sURL,Pos,1)  //el zoom
               else Ubic.Lat:=Ubic.Lat+Copy(sURL,Pos,1);   //la latitud
        Inc(Pos);
      end;
      Pos:=Pos+1;
    end;
    //se obtiene la longitud:
    while Pos<=Length(sURL) do
    begin
      Ubic.Lon:=Ubic.Lon+Copy(sURL,Pos,1);
      Inc(Pos);
    end;
  end;
end;

function CaractExiste(Strng: string; Charact: char): boolean;
var
  I: byte;
  Existe: boolean;
begin
  Existe:=false;
  for I:=1 to Length(Strng) do
  begin
    Existe:=Strng[I]=Charact;
    if Existe then Break;
  end;
  Result:=Existe;
end;

/// Eventos ///

procedure TFPrinc.BBuscarClick(Sender: TObject);
begin
  Ubication.Lat:=ELat.Text;
  Ubication.Lon:=ELon.Text;
  Ubication.Zoom:=Round(TrBarZoom.Value).ToString;
  Ubication.URLFull:=MapURL+'#map='+Ubication.Zoom+'/'+Ubication.Lat+'/'+Ubication.Lon;
  WebBrowser.URL:=Ubication.URLFull;
  WebBrowser.StartLoading;
end;

procedure TFPrinc.ELatChange(Sender: TObject);
begin
  TrBarZoom.Value:=StrToFloat(Ubication.Zoom);
end;

procedure TFPrinc.ELatKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if (KeyChar='.') and CaractExiste(TEdit(Sender).Text,'.') then KeyChar:=#0;
end;

procedure TFPrinc.FormCreate(Sender: TObject);
begin
  FormatSettings.DecimalSeparator:='.';
  WebBrowser.URL:='https://www.openstreetmap.org/export/embed.html?bbox='+
                  '-73.400,0.400,-59.700,12.600&layer=mapnik';
end;

procedure TFPrinc.FormShow(Sender: TObject);
begin
  //esto es una prueba:
  //LocSensor.Active:=SwGPS.IsChecked;
  LZoom.Text:=TrBarZoom.Value.ToString;
  //WebBrowser.URL:=MapURL;
  //WebBrowser.URL:='https://www.openstreetmap.org/#map=6/6.447/-66.579';
  WebBrowser.StartLoading;
end;

procedure TFPrinc.FrmAcerca1BAceptarClick(Sender: TObject);
begin
  LayAcerca.Visible:=false;
  LayPrinc.Visible:=true;
end;

procedure TFPrinc.LocSensorHeadingChanged(Sender: TObject;
  const AHeading: THeading);
begin
  if not IsNaN(AHeading.Azimuth) then
  begin
    LRumbo.Text:=FormatFloat('#0.#',AHeading.Azimuth)+'º '+
                 Orientacion(AHeading.Azimuth);
    ImgFlecha.RotationAngle:=AHeading.Azimuth;
  end;
end;

procedure TFPrinc.LocSensorLocationChanged(Sender: TObject; const OldLocation,
  NewLocation: TLocationCoord2D);
var
  UTM: TPosicion;
  Posc: TTile;
begin
  CargarCoordenadas(NewLocation,UTM);
  Ubication.Lat:=FormatFloat('#0.######',NewLocation.Latitude);
  Ubication.Lon:=FormatFloat('#0.######',NewLocation.Longitude);
  Ubication.Este:=Round(UTM.X).ToString+' E';
  Ubication.Norte:=Round(UTM.Y).ToString+' N';
  //Ubication.URLFull:=MapURL+'#map='+Ubication.Zoom+'/'+Ubication.Lat+'/'+Ubication.Lon;
  //Ubication.URLFull:='https://www.openstreetmap.org/export/embed.html?bbox='+
  Posc:=GetTileNumber(NewLocation,Ubication.Zoom.ToInteger);
  Ubication.URLFull:='https://tile.openstreetmap.org/'+Ubication.Zoom+
                     '/'+Posc.X.ToString+'/'+Posc.Y.ToString+'.png';
  if not IsNaN(NewLocation.Longitude) then
  begin
    ELon.Text:=Ubication.Lon;
    EEste.Text:=Ubication.Este;
  end;
  if not IsNaN(NewLocation.Latitude) then
  begin
    ELat.Text:=Ubication.Lat;
    ENorte.Text:=Ubication.Norte;
  end;
  WebBrowser.URL:=Ubication.URLFull;
  WebBrowser.StartLoading;
  showmessage(Ubication.URLFull);
end;

procedure TFPrinc.SBAcercaClick(Sender: TObject);
begin
  LayPrinc.Visible:=false;
  LayAcerca.Visible:=true;
end;

procedure TFPrinc.SBSalirClick(Sender: TObject);
begin
  {$IFDEF ANDROID}
  MainActivity.finish;
  {$ENDIF}
end;

procedure TFPrinc.SwGPSSwitch(Sender: TObject);
const
  PermissionAccessFineLocation='android.permission.ACCESS_FINE_LOCATION';
begin
  {$IFDEF ANDROID}
  PermissionsService.RequestPermissions([PermissionAccessFineLocation],
    procedure(const APermissions: TClassicStringDynArray;
              const AGrantResults: TClassicPermissionStatusDynArray)
    begin
      if (Length(AGrantResults)=1) and (AGrantResults[0]=TPermissionStatus.Granted) then
        LocSensor.Active:=SwGPS.IsChecked
      else
      begin
        SwGPS.IsChecked:=false;
        TDialogService.ShowMessage('Permiso de Localización no está permitido');
      end;
    end);
  {$ELSE}
    LocSensor.Active := SwitchGPS.IsChecked;
  {$ENDIF}
  ELon.ReadOnly:=SwGPS.IsChecked;
  ELat.ReadOnly:=SwGPS.IsChecked;
  Ubication.Zoom:=Round(TrBarZoom.Value).ToString;
end;

procedure TFPrinc.TrBarZoomChange(Sender: TObject);
begin
  Ubication.Zoom:=Round(TrBarZoom.Value).ToString;
  LZoom.Text:=Ubication.Zoom;
end;

procedure TFPrinc.WebBrowserDidFinishLoad(ASender: TObject);
begin
  {ParseURLToCoords(WebBrowser.URL,Ubication);
  ELat.Text:=Ubication.Lat;
  ELon.Text:=Ubication.Lon;
  TrBarZoom.Value:=StrToFloat(Ubication.Zoom);}
end;

end.

{ más ajustado a Venezuela:
https://www.openstreetmap.org/export/embed.html?bbox=
        -73.400,0.400,-59.700,12.600&layer=mapnik
}
