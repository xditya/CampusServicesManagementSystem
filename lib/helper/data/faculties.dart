class Faculties {
  final Map<String, Map<int, Map<int, List<String>>>> advisors = {
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

  final List<String> allFaculty = [
    'Dr. Faculty 1', 'Prof. Faculty 2', 'Dr. Faculty 3',
    // Add more faculty names...
  ];

  final Map<String, String> hods = {
    'CS': 'Dr. Jisha John',
    'EC': 'Dr. Luxy Mathews',
    'EEE': 'Dr. Elizabeth Varghese',
    'ME': 'Dr. Remil George Thomas',
    'CE': 'Dr. Jisha S.V',
    'EL': '',
  };

  final String principal = 'Dr. S. Viswanatha Rao';
}
