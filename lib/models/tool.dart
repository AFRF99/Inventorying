class Tool{
  String _id;
  String _name;
  String _descripcion;
  int _cantidad;
  int _canales;
  int _salidasVoltaje;
  int _salidasCorriente;
  bool _funcionOnda;
  bool _contadorPulsos;
  bool _pantallaTactil;
  String _urlPicture;

  Map<String, dynamic> toJson()=>{
    "id": _id,
    "name": _name,
    "descripcion": _descripcion,
    "cantidad": _cantidad,
    "canales": _canales,
    "salidasVoltaje": _salidasVoltaje,
    "salidasCorriente": _salidasCorriente,
    "funcionOnda": _funcionOnda,
    "contadorPulsos": _contadorPulsos,
    "pantallaTactil": _pantallaTactil,
    "urlPicture": _urlPicture,
  };

  Tool(this._id,
      this._name,
      this._descripcion,
      this._cantidad,
      this._canales,
      this._salidasVoltaje,
      this._salidasCorriente,
      this._funcionOnda,
      this._contadorPulsos,
      this._pantallaTactil,
      this._urlPicture);

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get urlPicture => _urlPicture;

  set urlPicture(String value) {
    _urlPicture = value;
  }

  bool get pantallaTactil => _pantallaTactil;

  set pantallaTactil(bool value) {
    _pantallaTactil = value;
  }

  bool get contadorPulsos => _contadorPulsos;

  set contadorPulsos(bool value) {
    _contadorPulsos = value;
  }

  bool get funcionOnda => _funcionOnda;

  set funcionOnda(bool value) {
    _funcionOnda = value;
  }

  int get salidasCorriente => _salidasCorriente;

  set salidasCorriente(int value) {
    _salidasCorriente = value;
  }

  int get salidasVoltaje => _salidasVoltaje;

  set salidasVoltaje(int value) {
    _salidasVoltaje = value;
  }

  int get canales => _canales;

  set canales(int value) {
    _canales = value;
  }

  int get cantidad => _cantidad;

  set cantidad(int value) {
    _cantidad = value;
  }

  String get descripcion => _descripcion;

  set descripcion(String value) {
    _descripcion = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }
}