import 'package:dam_u3_canciones/serviciosremotos.dart';
import 'package:flutter/material.dart';

class AppCancion extends StatefulWidget {
  const AppCancion({super.key});

  @override
  State<AppCancion> createState() => _AppCancionState();
}

class _AppCancionState extends State<AppCancion> {

  String titulo="YouTube Music";
  int _index=0;
  var actualizarJson;

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${titulo}"),
        centerTitle: true,
      ),
      body: dinamico(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Youtube Music", style: TextStyle(color: Colors.white, fontSize: 25),),
                SizedBox(height: 10,),
                CircleAvatar(child: Icon(Icons.play_circle_outline),),
                SizedBox(height: 30,),
                Text("Jesús Parra", style: TextStyle(color: Colors.white, fontSize: 20),)
              ],
            ),
              decoration: BoxDecoration(color: Colors.redAccent),
            ),
            _item(Icons.format_list_bulleted, "Lista", 0),
            _item(Icons.add, "Insertar", 1),
          ],
        ),
      ),

    );
  }

  Widget _item(IconData icono, String texto, int indice) {
    return ListTile(
      onTap: (){
        setState(() {
          _index = indice;
        });
        Navigator.pop(context);
      },
      title: Row(
        children: [Expanded(child: Icon(icono)), Expanded(child: Text(texto),flex: 2,)],
      ),
    );
  }

  Widget dinamico(){
    if(_index==1){
      titulo="YouTube Music";
      return capturar();
    }
    titulo="YouTube Music";
    return cargarData();
  }

  Widget cargarData() {
    return FutureBuilder(
      future: DB.mostrarTodos(),
      builder: (context, listaJSON) {
        if (listaJSON.hasData) {
          return ListView.builder(
            itemCount: listaJSON.data?.length,
            itemBuilder: (context, indice) {
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.music_note),
                ),
                title: Text("${listaJSON.data?[indice]['nombrecancion']}"),
                subtitle: Text("${listaJSON.data?[indice]['artista']}\n"
                    "${listaJSON.data?[indice]['lanzamiento']} - ${listaJSON.data?[indice]['genero']}"),
                trailing: IconButton(
                  onPressed: () {
                    // Mostrar AlertDialog para confirmar la eliminación
                    showDialog(
                      context: context,
                      builder: (builder) {
                        return AlertDialog(
                          title: Text("Advertencia"),
                          content: Text("¿Estás seguro de eliminar la canción?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                DB.eliminar(listaJSON.data?[indice]['id'])
                                    .then((value) {
                                  setState(() {
                                    titulo = "SE BORRÓ";
                                  });
                                  Navigator.pop(context);
                                });
                              },
                              child: Text("Eliminar"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancelar"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.delete),
                ),
                onTap: () {
                  setState(() {
                    actualizarJson = listaJSON.data?[indice];
                    actualizar();
                  });
                },
              );
            },
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  void actualizar() {
    final nombrecancion = TextEditingController();
    final artista = TextEditingController();
    final genero = TextEditingController();
    final lanzamiento = TextEditingController();

    nombrecancion.text = actualizarJson?['nombrecancion'];
    artista.text = actualizarJson?['artista'];
    genero.text = actualizarJson?['genero'];
    lanzamiento.text = (actualizarJson?['lanzamiento']).toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 5,
      builder: (builder) {
        return Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 30,
            right: 30,
            bottom: MediaQuery.of(context).viewInsets.bottom + 50,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombrecancion,
                decoration: InputDecoration(
                  icon: Icon(Icons.music_note),
                  labelText: "Canción:",
                ),
              ),
              SizedBox(height: 10,),
              TextField(
                controller: artista,
                decoration: InputDecoration(
                  icon: Icon(Icons.account_circle),
                  labelText: "Artista:",
                ),
              ),
              SizedBox(height: 10,),
              TextField(
                controller: genero,
                decoration: InputDecoration(
                  icon: Icon(Icons.headset),
                  labelText: "Género:",
                ),
              ),
              TextField(
                controller: lanzamiento,
                decoration: InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: "Año de Lanzamiento:",
                ),
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      var JSonTemporal = {
                        'id': actualizarJson?['id'],
                        'nombrecancion': nombrecancion.text,
                        'artista': artista.text,
                        'genero': genero.text,
                        'lanzamiento': int.parse(lanzamiento.text),
                      };
                      DB.actualizar(JSonTemporal)
                          .then((value) {
                        setState(() {
                          titulo = "SE ACTUALIZÓ";
                          nombrecancion.text = "";
                          artista.clear();
                          genero.clear();
                          lanzamiento.clear();
                          _index = 0;
                        });
                        Navigator.pop(context); // Cierra el BottomSheet después de actualizar.
                      });
                    },
                    child: Text("Actualizar"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cierra el BottomSheet al presionar Cancelar.
                      setState(() {
                        _index = 0;
                      });
                    },
                    child: Text("Cancelar"),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }


  Widget capturar(){
    final idcancion = TextEditingController();
    final nombrecancion = TextEditingController();
    final artista = TextEditingController();
    final genero = TextEditingController();
    final lanzamiento = TextEditingController();

    return ListView(
      padding: EdgeInsets.all(40),
      children: [
        TextField(
          controller: idcancion,
          decoration: InputDecoration(
              icon: Icon(Icons.vpn_key),
              labelText: "ID Canción"
          ),
        ),
        SizedBox(height: 10,),
        TextField(
          controller: nombrecancion,
          decoration: InputDecoration(
              icon: Icon(Icons.music_note),
              labelText: "Canción:"
          ),
        ),
        SizedBox(height: 10,),
        TextField(
          controller: artista,
          decoration: InputDecoration(
              icon: Icon(Icons.account_circle),
              labelText: "Artista:"
          ),
        ),
        SizedBox(height: 10,),
        TextField(
          controller: genero,
          decoration: InputDecoration(
              icon: Icon(Icons.headphones),
              labelText: "Género:"
          ),
        ),
        SizedBox(height: 10,),
        TextField(
          controller: lanzamiento,
          decoration: InputDecoration(
              icon: Icon(Icons.calendar_today),
              labelText: "Año de Lanzamiento:"
          ),
        ),
        SizedBox(height: 30,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: (){
                  var JSonTemporal={
                    'artista':artista.text,
                    'genero':genero.text,
                    'idcacnion':idcancion.text,
                    'lanzamiento':int.parse(lanzamiento.text),
                    'nombrecancion':nombrecancion.text,
                  };
                  DB.insertar(JSonTemporal)
                      .then((value) {
                    setState(() {
                      titulo="SE INSERTÓ";
                    });
                  });

                },
                child: Text("Insertar")
            ),
            ElevatedButton(
                onPressed: (){
                  setState(() {
                    _index = 0;
                  });
                },
                child: Text("Cancel")
            ),
          ],
        )
      ],
    );
  }

}
