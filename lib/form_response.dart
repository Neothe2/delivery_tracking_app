enum ResponseType { get, edit, add, delete }

class FormResponse {
  ResponseType type;
  dynamic body;

  FormResponse(this.type, this.body);
}
