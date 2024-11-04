class User {
  var _name;
  var _email;
  var _password;
  var _genre;
  var _isActionFavorite;
  var _isAdventureFavorite;
  var _isComicFavorite;
  var _isFantasyFavorite;
  var _isLoveFavorite;
  var _isTerrorFavorite;
  var _bornDate;
  var _city;

  User.Empty();

  Map<String, dynamic> toJson() => {
        "name": _name,
        "email": _email,
        "password": _password,
        "genre": _genre,
        "isActionFavorite": _isActionFavorite,
        "isAdventureFavorite": _isAdventureFavorite,
        "isComicFavorite": _isComicFavorite,
        "isFantasyFavorite": _isFantasyFavorite,
        "isLoveFavorite": _isLoveFavorite,
        "isTerrorFavorite": _isTerrorFavorite,
        "bornDate": _bornDate,
        "city": _city,
      };

  User.fromJson(Map<String, dynamic> json)
      : _name = json['name'],
        _email = json['email'],
        _password = json['password'],
        _genre = json['genre'],
        _isActionFavorite = json['isActionFavorite'],
        _isAdventureFavorite = json['isAdventureFavorite'],
        _isComicFavorite = json['isComicFavorite'],
        _isFantasyFavorite = json['isFantasyFavorite'],
        _isLoveFavorite = json['isLoveFavorite'],
        _isTerrorFavorite = json['isTerrorFavorite'],
        _bornDate = json['bornDate'],
        _city = json['city'];

  get name => _name;

  set name(value) {
    _name = value;
  }

  get email => _email;

  get bornDate => _bornDate;

  set bornDate(value) {
    _bornDate = value;
  }

  get isTerrorFavorite => _isTerrorFavorite;

  set isTerrorFavorite(value) {
    _isTerrorFavorite = value;
  }

  get isLoveFavorite => _isLoveFavorite;

  set isLoveFavorite(value) {
    _isLoveFavorite = value;
  }

  get isFantasyFavorite => _isFantasyFavorite;

  set isFantasyFavorite(value) {
    _isFantasyFavorite = value;
  }

  get isComicFavorite => _isComicFavorite;

  set isComicFavorite(value) {
    _isComicFavorite = value;
  }

  get isAdventureFavorite => _isAdventureFavorite;

  set isAdventureFavorite(value) {
    _isAdventureFavorite = value;
  }

  get isActionFavorite => _isActionFavorite;

  set isActionFavorite(value) {
    _isActionFavorite = value;
  }

  get genre => _genre;

  set genre(value) {
    _genre = value;
  }

  get password => _password;

  set password(value) {
    _password = value;
  }

  set email(value) {
    _email = value;
  }

  User(
      this._name,
      this._email,
      this._password,
      this._genre,
      this._isActionFavorite,
      this._isAdventureFavorite,
      this._isComicFavorite,
      this._isFantasyFavorite,
      this._isLoveFavorite,
      this._isTerrorFavorite,
      this._bornDate,
      this._city);

  get city => _city;

  set city(value) {
    _city = value;
  }
}
