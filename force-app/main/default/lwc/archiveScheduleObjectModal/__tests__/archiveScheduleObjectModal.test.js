import { createElement } from '@lwc/engine-dom';
import ArchiveScheduleObjectModal from 'c/archiveScheduleObjectModal';
import getActiveSchedules from '@salesforce/apex/DataArchiveScheduleController.getActiveSchedules';
import getSchedulesForObject from '@salesforce/apex/DataArchiveScheduleController.getSchedulesForObject';

// Mock Apex methods
jest.mock(
    '@salesforce/apex/DataArchiveScheduleController.getActiveSchedules',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/DataArchiveScheduleController.getSchedulesForObject',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

const MOCK_SCHEDULES = [
    {
        id: '001',
        objectName: 'Account',
        frequency: 'DAILY',
        dateField: 'CreatedDate',
        days: 30,
        status: 'Active'
    }
];

describe('c-archive-schedule-object-modal', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders the modal with title and Next button', () => {
        const element = createElement('c-archive-schedule-object-modal', {
            is: ArchiveScheduleObjectModal
        });
        document.body.appendChild(element);

        const title = element.shadowRoot.querySelector('h2');
        expect(title.textContent).toBe('Select Object For Scheduled Archive');

        const nextBtn = element.shadowRoot.querySelector('lightning-button[label="Next"]');
        expect(nextBtn).not.toBeNull();
    });

    it('Next button is disabled when no object selected', () => {
        const element = createElement('c-archive-schedule-object-modal', {
            is: ArchiveScheduleObjectModal
        });
        document.body.appendChild(element);

        const nextBtn = element.shadowRoot.querySelector('lightning-button');
        expect(nextBtn.disabled).toBe(true);
    });

    it('dispatches close event on close button click', () => {
        const element = createElement('c-archive-schedule-object-modal', {
            is: ArchiveScheduleObjectModal
        });
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('close', handler);

        const closeBtn = element.shadowRoot.querySelector('button[title="Close"]');
        closeBtn.click();

        expect(handler).toHaveBeenCalled();
    });

    it('shows View Scheduled Objects button', () => {
        const element = createElement('c-archive-schedule-object-modal', {
            is: ArchiveScheduleObjectModal
        });
        document.body.appendChild(element);

        const viewBtn = element.shadowRoot.querySelector(
            'lightning-button[icon-name="utility:date_time"]'
        );
        expect(viewBtn).not.toBeNull();
        expect(viewBtn.label).toBe('View Scheduled Objects');
    });
});