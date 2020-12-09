class JumbleModel {
  String text;
  int id;
  JumbleModel({this.id, this.text});

  @override
  bool operator == (Object model) => model is JumbleModel && model.id == this.id;
  @override
  int get hashCode => this.id;
}
