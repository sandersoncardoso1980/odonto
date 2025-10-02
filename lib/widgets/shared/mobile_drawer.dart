import 'package:flutter/material.dart';

class MobileDrawer extends StatelessWidget {
  const MobileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "RE",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "NOVA",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Odontologia",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Início"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text("Serviços"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/servicos');
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text("Profissionais"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profissionais');
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text("Sobre"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/sobre');
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text("Contato"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/contato');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text("Agendar Consulta"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/agendamento');
            },
          ),
        ],
      ),
    );
  }
}
