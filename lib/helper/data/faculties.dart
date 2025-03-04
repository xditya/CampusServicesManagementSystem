class Faculties {
  final Map<String, Map<int, Map<int, List<String>>>> advisors = {
    'ADMIN': {
      2025: {
        1: ['Admin'],
        2: ['Admin'],
      },
      2026: {
        1: ['Admin'],
        2: ['Admin'],
      },
      2027: {
        1: ['Admin'],
        2: ['Admin'],
      },
      2028: {
        1: ['Admin'],
        2: ['Admin'],
      }
    },
    'CS': {
      2025: {
        1: ['Prof. Sarah CS', 'Dr. Mike CS'],
        2: ['Ms. Gayathri K. S.', 'Mr. Anand Haridas'],
      },
      2026: {
        1: ['Mr. Shon J Das', 'Ms. Vijitha Robinson', 'Ms. Bibi Annie Oommen'],
        2: ['Ms. Jisha Jose', 'Mr. Ramjith R P', 'Ms. Gauri Shree V.K'],
      },
      2027: {
        1: ['Ms. S. Asha', 'Dr. Priya Mariam Raju', 'Ms. Anjali S'],
        2: ['Ms. Lino Zachariah', 'Mr. V. S. Shibu', 'Ms. Bibi Annie Oommen'],
      },
      2028: {
        1: ['Dr. John CS', 'Prof. Sarah CS', 'Dr. Mike CS'],
        2: ['Dr. John CS', 'Prof. Sarah CS', 'Dr. Mike CS'],
      }
    },
    'EC': {
      2025: {
        1: ['Mr. Shiras S. N.', 'Ms. Salga Ann Jacob', 'Ms.Merin Philip'],
        2: ['Dr. Swapna P. S.', 'Mr. Jinu Baby', 'Ms. Lakshmy S.'],
      },
      2026: {
        1: [
          'Dr. Vineetha Mathai',
          'Mr. Niyas K Haneefa',
          'Mr. Sherry Varghese George'
        ],
        2: ['Dr. Ancy S. Anselam', 'Ms. Gouri Nandhana'],
      },
      2027: {
        1: ['Mr. Anoop K. Johnson', 'Ms. Amritha B. J.', 'Ms. Nithya Mohanan'],
        2: ['Dr. Sreedevi P.', 'Mr. Arun J. S.', 'Ms. Deepa P. L.'],
      },
      2028: {
        1: ['Dr. Alice EC', 'Prof. Bob EC', 'Dr. Eve EC'],
        2: ['Dr. Alice EC', 'Prof. Bob EC', 'Dr. Eve EC'],
      }
    },
    'EEE': {
      2025: {
        1: ['Dr. Soumya A. V.', 'Mr. Aswin R B', 'Ms. Vandana P'],
      },
      2026: {
        1: [
          'Dr. Dishore S V',
          'Ms Shilpa Susan Peter',
          'Ms. Charivil Sojy Rajan'
        ],
      },
      2027: {
        1: ['Ms. Surasmi N L', 'Ms. Revathy K P', 'Mr. Ayush Vijayan'],
      },
      2028: {
        1: ['Dr. Tom EEE', 'Prof. Jane EEE', 'Dr. Sam EEE'],
        2: ['Dr. Tom EEE', 'Prof. Jane EEE', 'Dr. Sam EEE'],
      }
    },
    'ME': {
      2025: {
        1: [
          'Mr. Roshan George Koshy',
          'Mr. Vaisakh S Nair',
          'Ms. Ruby Maria Syriac'
        ],
      },
      2026: {
        1: ['Dr. Peter ME', 'Prof. Mary ME', 'Dr. Paul ME'],
        2: ['Dr. Peter ME', 'Prof. Mary ME', 'Dr. Paul ME'],
      },
      2027: {
        1: ['Dr. Peter ME', 'Prof. Mary ME', 'Dr. Paul ME'],
        2: ['Dr. Arvind P', 'Dr. Nidhi M B'],
      },
      2028: {
        1: ['Dr. Peter ME', 'Prof. Mary ME', 'Dr. Paul ME'],
        2: ['Dr. Peter ME', 'Prof. Mary ME', 'Dr. Paul ME'],
      }
    },
    'CE': {
      2025: {
        1: ['Dr. Minu Ann Peter', 'Mr. Sreeju Nair S B', 'Ms. Indhu Luke'],
        2: ['Dr. Anupama Krishna D', 'Mr. U P Govind', 'Ms. Rintu Johnson'],
      },
      2026: {
        1: ['Ms. Radhika P', 'Ms. Rakhi.J.H', 'Ms. Sangeetha Sajeev'],
        2: ['Dr. Alice Thomas', 'Mr. Sijo M Saji', 'Ms. Lekshmi Chandran M'],
      },
      2027: {
        1: ['Dr. David CE', 'Prof. Lisa CE', 'Dr. Mark CE'],
        2: ['Dr. Archana J. Satheesh', 'Ms. Ansu Mathew', 'Mr. Nitin S'],
      },
      2028: {
        1: ['Dr. David CE', 'Prof. Lisa CE', 'Dr. Mark CE'],
        2: ['Dr. David CE', 'Prof. Lisa CE', 'Dr. Mark CE'],
      }
    },
    'EL': {
      2026: {
        1: [
          'Dr. Sheryl Arulini. A',
          'Dr. Elizabeth Varghese',
          'Ms. Manju Sreekumar'
        ]
      },
      2027: {
        1: ['Dr. Anil J.', 'Ms. Neetha Chandran', 'Ms. P. Sandhya']
      },
      2028: {
        1: ['Mr. Midhun G.', 'Ms. Vrinda Prasad', 'Ms. Sheenu P.']
      },
    }
  };

  final Map<String, String> allFacultyEmails = {
    'Dr. Jisha John': 'jishajohn@mbcet.ac.in',
    'Ms. Gayathri K. S.': 'gayathri@mbcet.ac.in',
    'Mr. Anand Haridas': 'anandharidas@mbcet.ac.in',
    'Mr. Shon J Das': 'shonjdas@mbcet.ac.in',
    'Ms. Vijitha Robinson': 'vijitharobinson@mbcet.ac.in',
    'Ms. Bibi Annie Oommen': 'bibiannie@mbcet.ac.in',
    'Ms. Jisha Jose': 'jishajose@mbcet.ac.in',
    'Mr. Ramjith R P': 'ramjithrp@mbcet.ac.in',
    'Ms. Gauri Shree V.K': 'gaurishree@mbcet.ac.in',
    'Ms. S. Asha': 'asha@mbcet.ac.in',
    'Dr. Priya Mariam Raju': 'priyamariam@mbcet.ac.in',
    'Ms. Anjali S': 'anjalis@mbcet.ac.in',
    'Ms. Lino Zachariah': 'linozachariah@mbcet.ac.in',
    'Mr. V. S. Shibu': 'shibu@mbcet.ac.in',
    'Mr. Shiras S. N.': 'shiras@mbcet.ac.in',
    'Ms. Salga Ann Jacob': 'salgaann@mbcet.ac.in',
    'Ms. Merin Philip': 'merinphilip@mbcet.ac.in',
    'Dr. Swapna P. S.': 'swapnaps@mbcet.ac.in',
    'Mr. Jinu Baby': 'jinubaby@mbcet.ac.in',
    'Ms. Lakshmy S.': 'lakshmys@mbcet.ac.in',
    'Dr. Vineetha Mathai': 'vineethamathai@mbcet.ac.in',
    'Mr. Niyas K Haneefa': 'niyashaneefa@mbcet.ac.in',
    'Mr. Sherry Varghese George': 'sherryvarghese@mbcet.ac.in',
    'Dr. Ancy S. Anselam': 'ancyanselam@mbcet.ac.in',
    'Ms. Gouri Nandhana': 'gourinandhana@mbcet.ac.in',
    'Mr. Anoop K. Johnson': 'anoopjohnson@mbcet.ac.in',
    'Ms. Amritha B. J.': 'amrithabj@mbcet.ac.in',
    'Ms. Nithya Mohanan': 'nithyamohanan@mbcet.ac.in',
    'Dr. Sreedevi P.': 'sreedevi@mbcet.ac.in',
    'Mr. Arun J. S.': 'arunjs@mbcet.ac.in',
    'Ms. Deepa P. L.': 'deepapl@mbcet.ac.in',
    'Dr. Soumya A. V.': 'soumyaav@mbcet.ac.in',
    'Mr. Aswin R B': 'aswinrb@mbcet.ac.in',
    'Ms. Vandana P': 'vandanap@mbcet.ac.in',
    'Dr. Dishore S V': 'dishoresv@mbcet.ac.in',
    'Ms. Shilpa Susan Peter': 'shilpapeter@mbcet.ac.in',
    'Ms. Charivil Sojy Rajan': 'charivilrajan@mbcet.ac.in',
    'Ms. Surasmi N L': 'surasmil@mbcet.ac.in',
    'Ms. Revathy K P': 'revathykp@mbcet.ac.in',
    'Mr. Ayush Vijayan': 'ayushvijayan@mbcet.ac.in',
    'Mr. Roshan George Koshy': 'roshangeorge@mbcet.ac.in',
    'Mr. Vaisakh S Nair': 'vaisakh@mbcet.ac.in',
    'Ms. Ruby Maria Syriac': 'rubymaria@mbcet.ac.in',
    'Dr. Arvind P': 'arvindp@mbcet.ac.in',
    'Dr. Nidhi M B': 'nidhimb@mbcet.ac.in',
    'Dr. Minu Ann Peter': 'minuann@mbcet.ac.in',
    'Mr. Sreeju Nair S B': 'sreejunair@mbcet.ac.in',
    'Ms. Indhu Luke': 'indhuluke@mbcet.ac.in',
    'Dr. Anupama Krishna D': 'anupamakrishna@mbcet.ac.in',
    'Mr. U P Govind': 'upgovind@mbcet.ac.in',
    'Ms. Rintu Johnson': 'rintujohnson@mbcet.ac.in',
    'Ms. Radhika P': 'radhikap@mbcet.ac.in',
    'Ms. Rakhi J H': 'rakhijh@mbcet.ac.in',
    'Ms. Sangeetha Sajeev': 'sangeethasajeev@mbcet.ac.in',
    'Dr. Alice Thomas': 'alicethomas@mbcet.ac.in',
    'Mr. Sijo M Saji': 'sijosaji@mbcet.ac.in',
    'Ms. Lekshmi Chandran M': 'lekshmichandran@mbcet.ac.in',
    'Dr. Archana J. Satheesh': 'archanasatheesh@mbcet.ac.in',
    'Ms. Ansu Mathew': 'ansumathew@mbcet.ac.in',
    'Mr. Nitin S': 'nitins@mbcet.ac.in',
    'Dr. Sheryl Arulini. A': 'sherylarulini@mbcet.ac.in',
    'Dr. Elizabeth Varghese': 'elizabethvarghese@mbcet.ac.in',
    'Ms. Manju Sreekumar': 'manjusreekumar@mbcet.ac.in',
    'Dr. Anil J.': 'anilj@mbcet.ac.in',
    'Ms. Neetha Chandran': 'neethachandran@mbcet.ac.in',
    'Ms. P. Sandhya': 'sandhyap@mbcet.ac.in',
    'Mr. Midhun G.': 'midhung@mbcet.ac.in',
    'Ms. Vrinda Prasad': 'vrindaprasad@mbcet.ac.in',
    'Ms. Sheenu P.': 'sheenup@mbcet.ac.in',
    'Dr. S. Viswanatha Rao': 'principal@mbcet.ac.in',
    'Dr. Luxy Mathews': 'luxymathews@mbcet.ac.in',
    'Dr. Remil George Thomas': 'remilgeorge@mbcet.ac.in',
    'Dr. Jisha S.V': 'jishasv@mbcet.ac.in',
    'Admin': 'contact@xditya.me'
  };

  List<String> get allFaculty => allFacultyEmails.keys.toList();

  final Map<String, String> hods = {
    'CS': 'Dr. Jisha John',
    'EC': 'Dr. Luxy Mathews',
    'EEE': 'Dr. Elizabeth Varghese',
    'ME': 'Dr. Remil George Thomas',
    'CE': 'Dr. Jisha S.V',
    'EL': '',
    'ADMIN': 'Admin'
  };

  final String principal = 'Dr. S. Viswanatha Rao';
}
