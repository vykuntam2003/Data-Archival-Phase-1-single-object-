import { createElement } from '@lwc/engine-dom';
import ArchiveScheduleFrequencyModal from 'c/archiveScheduleFrequencyModal';

describe('c-archive-schedule-frequency-modal', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders the modal with title', () => {
        const element = createElement('c-archive-schedule-frequency-modal', {
            is: ArchiveScheduleFrequencyModal
        });
        document.body.appendChild(element);

        const title = element.shadowRoot.querySelector('h2');
        expect(title.textContent.trim()).toBe('Configure Schedule Frequency');
    });

    it('Confirm button is disabled when no frequency selected', () => {
        const element = createElement('c-archive-schedule-frequency-modal', {
            is: ArchiveScheduleFrequencyModal
        });
        document.body.appendChild(element);

        const confirmBtn = element.shadowRoot.querySelector(
            'lightning-button[label="Confirm Schedule"]'
        );
        expect(confirmBtn.disabled).toBe(true);
    });

    it('renders frequency radio group with options', () => {
        const element = createElement('c-archive-schedule-frequency-modal', {
            is: ArchiveScheduleFrequencyModal
        });
        document.body.appendChild(element);

        const radioGroup = element.shadowRoot.querySelector('lightning-radio-group');
        expect(radioGroup).not.toBeNull();
        expect(radioGroup.label).toBe('Choose Frequency');
    });

    it('renders time picker input', () => {
        const element = createElement('c-archive-schedule-frequency-modal', {
            is: ArchiveScheduleFrequencyModal
        });
        document.body.appendChild(element);

        const timeInput = element.shadowRoot.querySelector('lightning-input[type="time"]');
        expect(timeInput).not.toBeNull();
        expect(timeInput.label).toBe('Preferred Execution Time');
    });

    it('dispatches close event on close button click', () => {
        const element = createElement('c-archive-schedule-frequency-modal', {
            is: ArchiveScheduleFrequencyModal
        });
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('close', handler);

        const closeBtn = element.shadowRoot.querySelector('button[title="Close"]');
        closeBtn.click();

        expect(handler).toHaveBeenCalled();
    });
});