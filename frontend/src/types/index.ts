export interface User {
  id: number;
  name: string;
  email: string;
  role: 'Super Admin' | 'Staff Officer' | 'Citizen' | string;
  department: string;
  phone?: string;
  avatar?: string;
  pin?: string;
  last_otp_at?: string;
  created_at: string;
}

export interface SlotScheduleConfig {
  morning: {
    enabled: boolean;
    start: string;
    end: string;
  };
  afternoon: {
    enabled: boolean;
    start: string;
    end: string;
  };
  wholeDay: {
    enabled: boolean;
    hours: number;
  };
}

export const DEFAULT_SLOT_SCHEDULE: SlotScheduleConfig = {
  morning: {
    enabled: true,
    start: '08:00 AM',
    end: '12:00 PM',
  },
  afternoon: {
    enabled: true,
    start: '01:00 PM',
    end: '05:00 PM',
  },
  wholeDay: {
    enabled: true,
    hours: 24,
  },
};

export function getStoredSlotSchedule(type: 'facility' | 'parks'): SlotScheduleConfig {
  try {
    const raw = localStorage.getItem(`govserve_slots_${type}`);
    if (raw) {
      const parsed = JSON.parse(raw);
      if (parsed && parsed.morning && parsed.afternoon) {
        return {
          morning: {
            enabled: parsed.morning.enabled !== false,
            start: parsed.morning.start || '08:00 AM',
            end: parsed.morning.end || '12:00 PM',
          },
          afternoon: {
            enabled: parsed.afternoon.enabled !== false,
            start: parsed.afternoon.start || '01:00 PM',
            end: parsed.afternoon.end || '05:00 PM',
          },
          wholeDay: {
            enabled: parsed.wholeDay?.enabled !== false,
            hours: 24,
          },
        };
      }
    }
  } catch {}
  return DEFAULT_SLOT_SCHEDULE;
}

export interface Facility {
  id: number;
  name: string;
  category: 'Government Facility' | 'Park & Recreation';
  capacity: number;
  hourly_rate: number;
  morning_rate?: number;
  afternoon_rate?: number;
  location: string;
  amenities: string;
  status: 'Available' | 'Maintenance' | 'Reserved';
  image_url?: string;
  image_url_2?: string;
}

export interface FacilityReservation {
  id: number;
  reference_no: string;
  facility_id: number;
  facility_name?: string;
  facility_category?: string;
  facility_location?: string;
  hourly_rate?: number;
  applicant_name: string;
  applicant_email: string;
  applicant_phone: string;
  purpose: string;
  /** Event name as entered by the citizen — used for Parks & Recreation bookings */
  event_name?: string;
  /** Activity type for Parks bookings: LGU Activity (free), Sports Activity, or Other / Private Event */
  activity_type?: 'LGU Activity' | 'Sports Activity' | 'Other / Private Event';
  /** Base64 or URL of the LGU sponsorship proof document uploaded by citizen */
  sponsorship_photo_url?: string;
  special_equipment?: string[];
  event_date: string;
  start_time: string;
  end_time: string;
  attendees: number;
  status: 'Pending' | 'Pending Review' | 'Approved' | 'Pending Payment' | 'Waiting for Payment' | 'Paid' | 'Rejected' | 'Completed' | 'Cancelled';
  remarks?: string;
  created_at: string;
}

export interface CemeteryPlot {
  id: number;
  cemetery_name?: string;
  plot_code: string;
  section: string;
  block_no: string;
  lot_no: string;
  row_no?: number;
  col_no?: number;
  plot_type: 'Columbarium Niche' | 'Lawn Lot' | 'Mausoleum' | 'Ossuary';
  status: 'Available' | 'Reserved' | 'Occupied';
  price: number;
  deceased_name?: string;
  burial_date?: string;
  date_of_death?: string;
  permit_no?: string;
  contact_person?: string;
}

export interface BurialRecord {
  id: number;
  reference_no: string;
  permit_no: string;
  // Section A: Deceased Information
  deceased_name: string;
  date_of_birth?: string;
  date_of_death: string;
  cause_of_death?: string;
  deceased_address?: string;
  attending_physician?: string;
  // Section B: Burial Details
  burial_date: string;
  burial_time?: string;
  plot_id?: number;
  plot_code?: string;
  section?: string;
  cemetery_name?: string;
  plot_type?: string;
  // Section C: Applicant Information
  contact_person: string;
  applicant_relationship?: string;
  contact_phone: string;
  applicant_email?: string;
  applicant_address?: string;
  // Section D: Requirements
  death_certificate_url?: string;
  valid_id_url?: string;
  // Section E: Declaration
  declaration_accepted?: boolean;
  fee_amount?: number;
  status: 'Pending' | 'Pending Review' | 'Pending Payment' | 'Waiting for Payment' | 'Paid' | 'Approved' | 'Completed' | 'Rejected' | 'Cancelled';
  created_at: string;
}

export interface UtilityRequest {
  id: number;
  ticket_no: string;
  citizen_name: string;
  citizen_phone: string;
  service_type: 'Water Main Leak' | 'Low Water Pressure' | 'Drainage Declogging' | 'Canal Wall Repair' | 'Sewer Overflow' | 'Flash Flooding';
  location: string;
  affected_households?: string;
  photo_url?: string;
  description: string;
  urgency: 'Urgent' | 'High' | 'Normal';
  ai_priority_score: number;
  status: 'Pending' | 'Pending Review' | 'In Progress' | 'Dispatched' | 'Resolved' | 'Rejected' | 'Cancelled';
  assigned_team?: string;
  resolution_notes?: string;
  created_at: string;
  resolved_at?: string;
}

export interface Asset {
  id: number;
  asset_tag: string;
  name: string;
  category: 'Heavy Equipment' | 'Service Vehicle' | 'Facility Equipment' | 'Water Pump & Generator';
  serial_no?: string;
  purchase_date?: string;
  purchase_cost: number;
  current_condition: 'Operational' | 'Needs Maintenance' | 'Under Repair' | 'Decommissioned';
  assigned_department: string;
  last_maintenance_date?: string;
  next_maintenance_due?: string;
  ai_maintenance_alert?: string;
  specs?: string;
  image_url?: string;
  created_at: string;
}

export interface ActivityLog {
  id: number;
  user_name: string;
  action: string;
  module: string;
  details: string;
  timestamp: string;
}

export interface DashboardStats {
  totalFacilities: number;
  pendingReservations: number;
  approvedReservations: number;
  totalCemeteryPlots: number;
  occupiedPlots: number;
  availablePlots: number;
  totalBurials: number;
  openUtilityRequests: number;
  resolvedUtilityRequests: number;
  totalAssets: number;
  assetsNeedingMaintenance: number;
  systemStatus: string;
  uptime: string;
}
