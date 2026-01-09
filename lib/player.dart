import 'package:flutter/material.dart';
import 'package:sheet/route.dart';
import 'package:sheet/sheet.dart';



class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final draggableController = DraggableScrollableController();

    return Sheet(
      maxExtent: double.infinity,
            physics: AlwaysDraggableSheetPhysics(parent: PageScrollPhysics()),
            fit: SheetFit.loose,
            backgroundColor: Colors.transparent,
            minExtent: 80,
            // resizable: true,
            initialExtent: 80,
            child: Container(
      color: const Color.fromARGB(0, 0, 0, 0),
      child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.all(5),
                height: 70,
                
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text('Arrastra hacia arriba para ver el reproductor', style: TextStyle(color: Colors.white70)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Reproductor de Música', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 16),
              const Divider(color: Colors.white70),
              ListTile(
                leading: const Icon(Icons.skip_previous, color: Colors.white),
                title: const Text('Anterior', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.play_arrow, color: Colors.white),
                title: const Text('Reproducir', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.skip_next, color: Colors.white),
                title: const Text('Siguiente', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}