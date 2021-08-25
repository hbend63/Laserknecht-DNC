( Datei  : Zahn.vdf )
( Datum      : 05.12.2014)
( Werkstoff  : Stahlblech )
( Staerke    : 5.0 mm )
(-Schneidparameter-)
( Leistung   : 1950 W )
( Vorschub   : 2500. mm/min )
( Gasdruck   : 100 kPa )
( Duesenabstand   : 1 mm )
( Fokuslage   : 0 mm )
( Pulskanal   : 10
( Bearbeitung: LSS Schneiden )
(-Programmanfang-)
M16
G71G90 ( metrisch/absolut)
F5000.
G50X0.Y0. (NP setzen)
G39A0( K-System drehen)
G38X100.Y100.( Skalieren)
M53 (progP AUS)
M20  (Spiegeln AUS)
M48  (Gasauswahl AUS)
G41R0.15(Radiuskomp.)
(------------------------)
G57R5 ( UP Einstech EIN )
(------------------------)
F300.
M44 (43Luft /44O2/ 45N2 EIN)
M92 (90=Stahl /91=VA / 92=Alu)
M51 ( Puls Betrieb)
G55V31A2000 (P in V31)
M52 (ruft UP auf)
M15G4X0.1 (Kopf senken)
M70G4X0.3 (Shutter AUF)
M13G4X0.1 (Strahl EIN)
G58 (-- UP Ende --)
(----------------------)
G57R1 ( UP AK Laser EIN )
(------------------------)
G59R5 (UP Einstechen)
M44 (43Luft /44O2/ 45N2 EIN)
G4X0.5 ( Wartezeit Gastausch)
M50 (CW)
F2500.
G55V31A2000 (P in V31)
M52 (UP-Aufruf)
M13G4X0.2 (Strahl EIN)
G58 (-- UP Ende --)
(-------------------------)
G57R2 ( UP Innen Laser EIN )
(-------------------------)
G59R5 (UP Einstechen)
M44 (43Luft /44O2/ 45N2 EIN)
M50 (CW)
F2500.
G55V31A2000 (P in V31)
M52 (UP-Aufruf)
M13G4X0.2 (Strahl EIN)
G58 (-- UP Ende --)
(------------------------)
G57R3 ( UP InnenKl Laser EIN )
(------------------------)
G59R5 (UP Einstechen)
M44 (43Luft /44O2/ 45N2 EIN)
M50 (CW)
F2000.
G55V31A2000 (P in V31)
M52 (UP-Aufruf)
M13G4X0.2 (Strahl EIN)
G58 (-- UP Ende --)
(----------------------)
G57R4 ( UP Grav EIN )
(------------------------)
F3000.
M44 (43Luft /44O2/ 45N2 EIN)
M85 (Pulskanal 5)
M51 ( Puls Betrieb)
G55V31A2000 (2kW in V31)
M52 (ruft UP auf)
M15G4X0.1 (Kopf senken)
M70G4X0.3 (Shutter AUF)
M13G4X1.0 (Strahl EIN)
G58 (-- UP Ende --)
(------------------------)
G57R50 UP Laser AUS)
(------------------------)
M14 (Strahl AUS   )
M16 ( Kopf heben )
M72 (Shutter Zu)
M53 (progP Loeschen)
G58 (-- UP Ende --)
(------------------------)
(Kontur anfahren)
G00 X37.83 Y45.7
G59R2 (-UP INNEN EIN-)
(-Kontur bearbeiten-)
G03 X34.26 Y55.04 I-1.78 J4.67
G03 X30.58 Y53.06 I5.74 J-15.04
G01 X29.97 Y53.54
G01 X25.86 Y49.16
G01 X26.38 Y48.58
G03 X24.4 Y43.99 I13.62 J-8.58 
G01 X23.62 Y43.97 
G01 X23.27 Y37.98 
G01 X24.04 Y37.86 
G03 X25.47 Y33.07 I15.96 J2.14 
G01 X24.88 Y32.56 
G01 X28.45 Y27.73 
G01 X29.11 Y28.14 
G03 X33.17 Y25.42 I10.89 J11.86 
G01 X33.04 Y24.65 
G01 X38.86 Y23.19 
G01 X39.12 Y23.92 
G03 X44.09 Y24.43 I0.88 J16.08 
G01 X44.49 Y23.76 
G01 X49.89 Y26.36 
G01 X49.62 Y27.09 
G03 X53.12 Y30.66 I-9.62 J12.91 
G01 X53.85 Y30.4 
G01 X56.33 Y35.86 
G01 X55.66 Y36.25 
G03 X56.05 Y41.23 I-15.66 J3.75 
G01 X56.78 Y41.5 
G01 X55.19 Y47.29 
G01 X54.43 Y47.15 
G03 X51.54 Y51.23 I-14.43 J-7.15 
G01 X51.92 Y51.9 
G01 X47.0 Y55.33 
G01 X46.5 Y54.73 
G03 X41.67 Y56.01 I-6.50 J-14.73 
G01 X41.6 Y56.77 
G01 X38.4 Y56.77 
G01 X38.33 Y56.01 
G03 X34.26 Y55.04 I1.67 J-16.01 
G59R50 (UP Laser AUS)
G00 X40.0 Y67.5 
G59R2 (-UP INNEN EIN-)
(-Kontur bearbeiten-)
G03 X43.25 Y67.5 I1.63 J0.00 
G03 X43.25 Y67.5 I-3.25 J0.00 
G59R50 (UP Laser AUS)
G00 X67.5 Y40.0 
G59R2 (-UP INNEN EIN-)
(-Kontur bearbeiten-)
G03 X70.75 Y40.0 I1.63 J0.00 
G03 X70.75 Y40.0 I-3.25 J0.00 
G59R50 (UP Laser AUS)
G00 X40.0 Y12.5 
G59R2 (-UP INNEN EIN-)
(-Kontur bearbeiten-)
G03 X43.25 Y12.5 I1.63 J0.00 
G03 X43.25 Y12.5 I-3.25 J0.00 
G59R50 (UP Laser AUS)
G00 X12.5 Y40.0 
G59R2 (-UP INNEN EIN-)
(-Kontur bearbeiten-)
G03 X15.75 Y40.0 I1.63 J0.00 
G03 X15.75 Y40.0 I-3.25 J0.00 
G59R50 (UP Laser AUS)
G00 X0.02 Y9.98 
G59R1 (-UP aussen EIN-)
(-Kontur bearbeiten-)
G03 X8.01 Y15.98 I4.00 J3.00 
G02 X8.01 Y15.98 I31.99 J24.02 
G59R50 (UP Laser AUS)
(---- Konturende----)
M14  ( Strahl aus)
M16  (Kopf heben)
M72  (Shutter schliessen)
M53  (progP AUS)
M48  (Gasauswahl AUS)
G40 (Radiuskomp. AUS)
G00X0.Y0.
M02 (ENDE   )
(-----------------------)
