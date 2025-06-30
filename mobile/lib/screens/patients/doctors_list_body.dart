import 'package:flutter/material.dart';

class DoctorsListBody extends StatelessWidget {
  const DoctorsListBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Remplacer ce Container par le contenu principal de la liste des médecins
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Exemple de médecin
        Card(
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Dr. Sophie Martin'),
            subtitle: Text('Cardiologue'),
            onTap: () {
              // Naviguer vers le profil du médecin
            },
          ),
        ),
        // ... autres médecins ...
      ],
    );
  }
}
