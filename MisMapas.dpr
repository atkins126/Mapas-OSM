{
    Mis Mapas
      v1.0

   Aplicaci�n simple que muestra un mapa en un componente TWebBrowser, bas�ndose
   en los mapas de https://www.openstreetmap.org/

   Autor: Ing. Francisco J. S�ez S.
   email: fjsaez@gmail.com

   Calabozo, septiembre de 2019.
}

program MisMapas;

uses
  System.StartUpCopy,
  {$IFDEF ANDROID}
  Androidapi.JNI.App,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.Helpers,
  {$ENDIF}
  FMX.Forms,
  Principal in 'Principal.pas' {FPrinc},
  AcercaFrm in 'AcercaFrm.pas' {FAcerca};

{$R *.res}

begin
  Application.Initialize;
  {$IFDEF ANDROID}
    SharedActivity.getWindow.addFlags(
      TJWindowManager_LayoutParams.JavaClass.FLAG_KEEP_SCREEN_ON);
  {$ENDIF}
  Application.FormFactor.Orientations := [TFormOrientation.Portrait,
    TFormOrientation.InvertedPortrait, TFormOrientation.Landscape,
    TFormOrientation.InvertedLandscape];
  Application.CreateForm(TFPrinc, FPrinc);
  Application.Run;
end.
