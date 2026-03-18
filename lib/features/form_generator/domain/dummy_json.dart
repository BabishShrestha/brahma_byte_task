const _formJson = {
  "form": {
    "title": "Car Insurance Application",
    "steps": [
      {
        "title": "Personal Information",

        "description": "Enter your basic personal details.",
        "inputs": [
          {
            "key": "fullName",
            "type": "text",
            "label": "Full Name",
            "required": true,
          },
          {
            "key": "age",
            "type": "text",
            "label": "Age",
            "required": true,
            "default": 18,
            "validation": {"numberOnly": true},
          },
          {
            "key": "gender",
            "type": "dropdown",
            "label": "Gender",
            "options": ["Male", "Female", "Other"],
            "required": true,
          },
        ],
      },
      {
        "title": "Vehicle Details",
        "description": "Provide information about your vehicle.",
        "inputs": [
          {
            "key": "vehicleType",
            "type": "dropdown",
            "label": "Vehicle Type",
            "default": "Motorbike",
            "options": ["Car", "Motorbike", "Truck"],
            "required": true,
          },
          {
            "key": "vehicleYear",
            "type": "text",
            "label": "Vehicle Manufacture Year",
            "required": true,
            "validation": {"numberOnly": true},
          },
          {
            "key": "hasExistingInsurance",
            "type": "toggle",
            "label": "Do you currently have insurance?",
            "default": false,
            "required": false,
          },
        ],
      },
      {
        "title": "Coverage Preferences",
        "description": "Select the type of coverage you prefer.",
        "inputs": [
          {
            "key": "coverageType",
            "type": "dropdown",
            "label": "Coverage Type",
            "options": ["Third-Party", "Comprehensive", "Own Damage Only"],
            "required": true,
          },
          {
            "key": "roadsideAssistance",
            "type": "toggle",
            "label": "Include Roadside Assistance?",
            "required": false,
          },
        ],
      },
      {
        "title": "Review & Submit",
        "description": "Review your inputs before submitting the form.",
        "inputs": [],
      },
    ],
  },
};
